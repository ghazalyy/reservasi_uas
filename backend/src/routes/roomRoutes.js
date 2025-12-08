const express = require('express');
const router = express.Router();
const { getAllRooms, getRoomById, createRoom } = require('../controllers/roomController');
const { verifyToken, checkRole } = require('../middlewares/auth');
const upload = require('../middlewares/upload'); 

// Routes Publik
router.get('/', getAllRooms);
router.get('/:id', getRoomById);

// Route Admin 
router.post('/', verifyToken, checkRole('ADMIN'), upload.single('image'), createRoom); 

module.exports = router;