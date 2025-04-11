const User = require('../models/User');

exports.saveRoute = async (req, res) => {
    try {
        const { startLocation, endLocation, frequentlyUsed } = req.body;
        const user = await User.findById(req.user.userId);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const newRoute = {
            startLocation,
            endLocation,
            frequentlyUsed: frequentlyUsed || false,
            lastUsed: new Date()
        };

        user.savedRoutes.push(newRoute);
        await user.save();

        res.status(201).json(newRoute);
    } catch (error) {
        console.error('Save route error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getSavedRoutes = async (req, res) => {
    try {
        const user = await User.findById(req.user.userId);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json(user.savedRoutes);
    } catch (error) {
        console.error('Get routes error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateRoute = async (req, res) => {
    try {
        const { routeId } = req.params;
        const updates = req.body;
        const user = await User.findById(req.user.userId);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const routeIndex = user.savedRoutes.findIndex(route => route._id.toString() === routeId);
        
        if (routeIndex === -1) {
            return res.status(404).json({ message: 'Route not found' });
        }

        user.savedRoutes[routeIndex] = {
            ...user.savedRoutes[routeIndex].toObject(),
            ...updates,
            lastUsed: new Date()
        };

        await user.save();
        res.json(user.savedRoutes[routeIndex]);
    } catch (error) {
        console.error('Update route error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteRoute = async (req, res) => {
    try {
        const { routeId } = req.params;
        const user = await User.findById(req.user.userId);
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.savedRoutes = user.savedRoutes.filter(route => route._id.toString() !== routeId);
        await user.save();

        res.json({ message: 'Route deleted successfully' });
    } catch (error) {
        console.error('Delete route error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};
