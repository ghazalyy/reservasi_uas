// src/app.js
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes'); 
const roomRoutes = require('./routes/roomRoutes');    
const hotelRoutes = require('./routes/hotelRoutes');       
const bookingRoutes = require('./routes/bookingRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const path = require('path');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// IZINKAN AKSES KE FOLDER PUBLIC
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));

// Routes Utama
app.use('/api/auth', authRoutes);
app.use('/api/hotels', hotelRoutes);
app.use('/api/rooms', roomRoutes);                
app.use('/api/bookings', bookingRoutes);
app.use('/api/reviews', reviewRoutes);

// Route Default
app.get('/', (req, res) => {
  res.send('API Hotel Reservation Ready!');
});

module.exports = app;