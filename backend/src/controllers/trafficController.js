const mongoose = require('mongoose');
const TrafficReport = require('../models/TrafficReport');

exports.reportTraffic = async (req, res) => {
    try {
        const { location, congestionLevel, description } = req.body;
        const report = new TrafficReport({
            userId: req.user.userId,
            location,
            congestionLevel,
            description
        });
        
        await report.save();
        res.status(201).json(report);
    } catch (error) {
        console.error('Traffic report error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getNearbyTraffic = async (req, res) => {
    try {
        const { latitude, longitude, radius = 5000 } = req.query; // radius in meters
        
        const reports = await TrafficReport.find({
            'location.coordinates': {
                $near: {
                    $geometry: {
                        type: 'Point',
                        coordinates: [parseFloat(longitude), parseFloat(latitude)]
                    },
                    $maxDistance: radius
                }
            },
            createdAt: { $gte: new Date(Date.now() - 30 * 60 * 1000) } // Last 30 minutes
        }).limit(50);
        
        res.json(reports);
    } catch (error) {
        console.error('Get traffic error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};
