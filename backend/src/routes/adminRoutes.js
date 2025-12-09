const express = require('express');
const router = express.Router();
const { getDashboardStats, exportBookingsCSV } = require('../controllers/dashboardController');
const { verifyToken, checkRole } = require('../middlewares/auth');

// Dashboard Stats (JSON)
router.get('/dashboard', verifyToken, checkRole('ADMIN'), getDashboardStats);
router.get('/export', verifyToken, checkRole('ADMIN'), exportBookingsCSV);

module.exports = router;