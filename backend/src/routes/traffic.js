const express = require('express');
const trafficController = require('../controllers/trafficController');
const auth = require('../middleware/auth');

const router = express.Router();

router.use(auth);

router.post('/report', trafficController.reportTraffic);
router.get('/nearby', trafficController.getNearbyTraffic);

module.exports = router;
