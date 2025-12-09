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

// UPDATE ROOM
const updateRoom = async (req, res) => {
  const { id } = req.params;
  const { type, price, capacity, isAvailable } = req.body;

  try {
    let dataToUpdate = {
        type,
        price: parseFloat(price),
        capacity: Number(capacity),
        isAvailable: isAvailable === 'true' || isAvailable === true // Handle boolean
    };

    // Jika ada upload gambar baru
    if (req.file) {
      dataToUpdate.imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
    }

    const updatedRoom = await prisma.room.update({
      where: { id: Number(id) },
      data: dataToUpdate
    });

    response(200, updatedRoom, "Room updated successfully", res);
  } catch (error) {
    response(500, null, error.message, res);
  }
};

// DELETE ROOM
const deleteRoom = async (req, res) => {
  const { id } = req.params;
  try {
    // Hapus booking terkait dulu (jika ada) atau biarkan error (tergantung kebijakan)
    // Disini kita hapus roomnya saja, jika ada booking mungkin akan error constraint
    // Idealnya booking di set null atau dihapus dulu.
    
    await prisma.booking.deleteMany({ where: { roomId: Number(id) } }); // Hapus history booking kamar ini

    await prisma.room.delete({
      where: { id: Number(id) }
    });

    response(200, null, "Room deleted successfully", res);
  } catch (error) {
    response(500, null, error.message, res);
  }
};

module.exports = { 
  createRoom, 
  getAllRooms, 
  getRoomById, 
  updateRoom, 
  deleteRoom  
};