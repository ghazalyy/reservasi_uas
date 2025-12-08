const express = require('express');
const router = express.Router();
const { createBooking, getMyBookings } = require('../controllers/bookingController');

const { verifyToken } = require('../middlewares/auth'); 

router.post('/', verifyToken, createBooking);
router.get('/my', verifyToken, getMyBookings);

module.exports = router;