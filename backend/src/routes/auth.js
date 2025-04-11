const express = require('express');
const { check } = require('express-validator');
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

const router = express.Router();

// Register user
router.post('/register', [
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password must be 6 or more characters').isLength({ min: 6 })
], authController.register);

// Login user
router.post('/login', [
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password is required').exists()
], authController.login);

// Get user profile
router.get('/profile', auth, authController.getProfile);

// Update user preferences
router.put('/preferences', auth, authController.updatePreferences);

module.exports = router;
