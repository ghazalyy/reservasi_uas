// src/routes/reviewRoutes.js
const express = require('express');
const router = express.Router();
const { createReview, getReviewsByHotel } = require('../controllers/reviewController');

const { verifyToken } = require('../middlewares/auth'); 

router.post('/', verifyToken, createReview); 
router.get('/:hotelId', getReviewsByHotel);

module.exports = router;