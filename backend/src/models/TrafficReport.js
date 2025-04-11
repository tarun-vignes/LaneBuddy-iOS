const mongoose = require('mongoose');

const trafficReportSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            required: true
        },
        coordinates: {
            type: [Number],
            required: true
        }
    },
    congestionLevel: {
        type: String,
        enum: ['low', 'medium', 'high', 'severe'],
        required: true
    },
    description: {
        type: String,
        maxLength: 500
    },
    createdAt: {
        type: Date,
        default: Date.now,
        expires: 1800 // Document expires after 30 minutes
    }
});

// Create geospatial index
trafficReportSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('TrafficReport', trafficReportSchema);
