const express = require('express');
const routeController = require('../controllers/routeController');
const auth = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(auth);

// Save a new route
router.post('/', routeController.saveRoute);

// Get all saved routes
router.get('/', routeController.getSavedRoutes);

// Update a route
router.put('/:routeId', routeController.updateRoute);

// Delete a route
router.delete('/:routeId', routeController.deleteRoute);

module.exports = router;
