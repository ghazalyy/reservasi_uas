const prisma = require('../config/db');
const response = require('../utils/response');

// Buat Review baru (Dengan Validasi Booking)
const createReview = async (req, res) => {
  const { hotelId, rating, comment } = req.body;
  const userId = req.user.id; // Dari token

  try {
    // 1. CEK VALIDASI: Apakah user pernah booking di hotel ini dengan status CONFIRMED?
    const hasStayed = await prisma.booking.findFirst({
      where: {
        userId: userId,
        status: 'CONFIRMED', 
        room: {
          hotelId: Number(hotelId) 
        }
      }
    });

    // Jika tidak ditemukan riwayat booking
    if (!hasStayed) {
      return response(403, null, "Anda harus menginap (booking confirmed) di hotel ini sebelum memberi review.", res);
    }

    // 2. CEK DUPLIKASI (Opsional): Mencegah user review berkali-kali untuk hotel yang sama
    const existingReview = await prisma.review.findFirst({
        where: {
            userId: userId,
            hotelId: Number(hotelId)
        }
    });

    if (existingReview) {
        return response(400, null, "Anda sudah memberikan review untuk hotel ini.", res);
    }

    // 3. Simpan Review
    const review = await prisma.review.create({
      data: {
        userId,
        hotelId: Number(hotelId),
        rating: Number(rating),
        comment
      }
    });
    
    // 4. Update Rating Rata-rata Hotel
    const aggregations = await prisma.review.aggregate({
      _avg: { rating: true },
      where: { hotelId: Number(hotelId) }
    });
    
    await prisma.hotel.update({
      where: { id: Number(hotelId) },
      data: { rating: aggregations._avg.rating }
    });

    response(201, review, "Review berhasil ditambahkan", res);

  } catch (error) {
    console.log(error);
    response(500, null, "Gagal menambahkan review", res);
  }
};

// Ambil review berdasarkan Hotel ID (Tidak berubah)
const getReviewsByHotel = async (req, res) => {
  const { hotelId } = req.params;
  try {
    const reviews = await prisma.review.findMany({
      where: { hotelId: Number(hotelId) },
      include: { user: { select: { name: true } } },
      orderBy: { createdAt: 'desc' } // Urutkan dari yang terbaru
    });
    response(200, reviews, "List review hotel", res);
  } catch (error) {
    response(500, null, error.message, res);
  }
};

module.exports = { createReview, getReviewsByHotel };