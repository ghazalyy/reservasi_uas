const prisma = require('../config/db');
const response = require('../utils/response');

const createRoom = async (req, res) => {
  // 1. Ambil data text & file
  const { type, price, capacity, hotelId } = req.body;
  
  // 2. Proses URL Gambar
  const imageUrl = req.file 
    ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` 
    : null;

  try {
    // 3. Cek apakah hotel ada
    const hotelExists = await prisma.hotel.findUnique({ 
        where: { id: Number(hotelId) } 
    });
    if (!hotelExists) return response(404, null, "Hotel not found", res);

    // 4. Simpan ke Database
    const room = await prisma.room.create({
      data: {
        type,
        price: parseFloat(price),   
        capacity: Number(capacity), 
        hotelId: Number(hotelId),   
        imageUrl: imageUrl          
      }
    });
    
    response(201, room, "Room created successfully", res);
  } catch (error) {
    response(500, null, error.message, res);
  }
};

const getAllRooms = async (req, res) => {
    try {
        const rooms = await prisma.room.findMany({
            include: { hotel: true }
        });
        response(200, rooms, "All rooms fetched", res);
    } catch (error) {
        response(500, null, error.message, res);
    }
}

const getRoomById = async (req, res) => {
    const { id } = req.params;
    try {
        const room = await prisma.room.findUnique({
            where: { id: Number(id) },
            include: { hotel: true }
        });
        if(!room) return response(404, null, "Room not found", res);
        response(200, room, "Room detail fetched", res);
    } catch (error) {
        response(500, null, error.message, res);
    }
}

module.exports = { createRoom, getAllRooms, getRoomById };