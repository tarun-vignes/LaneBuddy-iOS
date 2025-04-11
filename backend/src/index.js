require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const routeRoutes = require('./routes/routes');
const trafficRoutes = require('./routes/traffic');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/traffic', trafficRoutes);

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI)
    .then(() => {
        console.log('Connected to MongoDB');
        // Create indexes
        const User = require('./models/User');
        const TrafficReport = require('./models/TrafficReport');
        
        // User indexes
        User.collection.createIndex({ email: 1 }, { unique: true });
        User.collection.createIndex({ 'savedRoutes.lastUsed': -1 });
        
        // Traffic report indexes
        TrafficReport.collection.createIndex({ location: '2dsphere' });
        TrafficReport.collection.createIndex({ createdAt: 1 }, { expireAfterSeconds: 1800 });
    })
    .catch(err => console.error('MongoDB connection error:', err));

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    if (err.name === 'ValidationError') {
        return res.status(400).json({ message: err.message });
    }
    if (err.name === 'UnauthorizedError') {
        return res.status(401).json({ message: 'Invalid token' });
    }
    res.status(500).json({ message: 'Something went wrong!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
