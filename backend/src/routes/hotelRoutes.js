const express = require('express');
const router = express.Router();
const { createHotel, getAllHotels, getHotelById } = require('../controllers/hotelController');
// Import checkRole
const { verifyToken, checkRole } = require('../middlewares/auth');
const upload = require('../middlewares/upload');

router.get('/', getAllHotels);
router.get('/:id', getHotelById);

// Hanya ADMIN yang bisa POST hotel
router.post('/', verifyToken, checkRole('ADMIN'), upload.single('image'), createHotel);

module.exports = router;