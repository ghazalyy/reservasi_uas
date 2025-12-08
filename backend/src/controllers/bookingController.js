const prisma = require('../config/db');
const response = require('../utils/response');

const createBooking = async (req, res) => {
  const { roomId, checkIn, checkOut } = req.body;
  const userId = req.user.id; // Dari token JWT

  try {
    const room = await prisma.room.findUnique({ where: { id: Number(roomId) } });
    if (!room) return response(404, null, "Room not found", res);

    const startDate = new Date(checkIn);
    const endDate = new Date(checkOut);
    const dayDiff = Math.ceil((endDate - startDate) / (1000 * 3600 * 24));

    if (dayDiff <= 0) return response(400, null, "Invalid dates", res);

    const totalPrice = dayDiff * room.price;

    const booking = await prisma.booking.create({
      data: {
        userId,
        roomId: Number(roomId),
        checkIn: startDate,
        checkOut: endDate,
        totalPrice,
        status: "PENDING" // Default Enum BookingStatus
      }
    });

    response(201, booking, "Booking created", res);
  } catch (error) {
    console.log(error);
    response(500, null, "Booking failed", res);
  }
};

const getMyBookings = async (req, res) => {
  const userId = req.user.id;
  try {
    const bookings = await prisma.booking.findMany({
      where: { userId },
      include: { 
        room: {
            include: { hotel: true } // Include Hotel info
        } 
      }
    });
    response(200, bookings, "User bookings", res);
  } catch (error) {
    response(500, null, "Error fetching bookings", res);
  }
};

module.exports = { createBooking, getMyBookings };