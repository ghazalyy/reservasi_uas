const prisma = require('../config/db');
const response = require('../utils/response');

const createHotel = async (req, res) => {
  // Data text ada di req.body, Data file ada di req.file
  const { name, address, description } = req.body;
  
  // Ambil path gambar jika ada upload
  // Hasil: http://localhost:3000/uploads/namafile.jpg
  const imageUrl = req.file 
    ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` 
    : null;

  try {
    const hotel = await prisma.hotel.create({
      data: { 
        name, 
        address, 
        description, 
        imageUrl: imageUrl // Simpan URL yang digenerate tadi
      }
    });
    response(201, hotel, "Hotel created successfully", res);
  } catch (error) {
    response(500, null, error.message, res);
  }
};

// Get All Hotels (dengan data kamar)
const getAllHotels = async (req, res) => {
  try {
    const hotels = await prisma.hotel.findMany({
      include: { rooms: true } // Include agar user bisa lihat kamar apa saja yg ada
    });
    response(200, hotels, "List of hotels", res);
  } catch (error) {
    response(500, null, "Error fetching hotels", res);
  }
};

// Get Hotel Detail (dengan review)
const getHotelById = async (req, res) => {
  const { id } = req.params;
  try {
    const hotel = await prisma.hotel.findUnique({
      where: { id: Number(id) },
      include: { 
        rooms: true,
        reviews: {
          include: { user: { select: { name: true } } } // Lihat nama pereview
        }
      }
    });
    if (!hotel) return response(404, null, "Hotel not found", res);
    response(200, hotel, "Hotel details", res);
  } catch (error) {
    response(500, null, "Error fetching hotel", res);
  }
};

module.exports = { createHotel, getAllHotels, getHotelById };