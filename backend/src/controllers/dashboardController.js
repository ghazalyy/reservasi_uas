const prisma = require('../config/db');
const response = require('../utils/response');

// 1. GET STATISTIK & DATA GRAFIK
const getDashboardStats = async (req, res) => {
  try {
    // A. Ringkasan Atas (Total User, Hotel, Pendapatan)
    const totalUsers = await prisma.user.count({ where: { role: 'USER' } });
    const totalHotels = await prisma.hotel.count();
    const totalBookings = await prisma.booking.count();
    
    // Hitung Total Pendapatan (Hanya yang status CONFIRMED)
    const revenueAgg = await prisma.booking.aggregate({
      _sum: { totalPrice: true },
      where: { status: 'CONFIRMED' }
    });
    const totalRevenue = revenueAgg._sum.totalPrice || 0;

    // B. Data Grafik (Pendapatan per Bulan - Tahun Ini)
    const currentYear = new Date().getFullYear();
    const startOfYear = new Date(`${currentYear}-01-01`);
    const endOfYear = new Date(`${currentYear}-12-31`);

    const bookings = await prisma.booking.findMany({
      where: {
        createdAt: { gte: startOfYear, lte: endOfYear },
        status: 'CONFIRMED'
      },
      select: { createdAt: true, totalPrice: true }
    });

    let monthlyRevenue = Array(12).fill(0);
    let monthlyBookings = Array(12).fill(0);

    bookings.forEach(booking => {
      const month = new Date(booking.createdAt).getMonth(); 
      monthlyRevenue[month] += booking.totalPrice;
      monthlyBookings[month] += 1;
    });

    const data = {
      summary: { totalUsers, totalHotels, totalBookings, totalRevenue },
      chartData: {
        revenue: monthlyRevenue,
        bookings: monthlyBookings,
        labels: ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"]
      }
    };

    response(200, data, "Dashboard stats fetched", res);
  } catch (error) {
    console.log(error);
    response(500, null, error.message, res);
  }
};

// 2. EXPORT CSV 
const exportBookingsCSV = async (req, res) => {
  try {
    const bookings = await prisma.booking.findMany({
      include: {
        user: { select: { name: true, email: true } },
        room: { 
          include: { hotel: { select: { name: true } } } 
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    let csv = "ID,Hotel,User Name,User Email,Check In,Check Out,Status,Total Price,Created At\n";

    bookings.forEach(b => {
      const hotelName = b.room.hotel.name.replace(/,/g, ''); 
      const userName = b.user.name.replace(/,/g, '');
      const checkIn = b.checkIn.toISOString().split('T')[0];
      const checkOut = b.checkOut.toISOString().split('T')[0];
      const date = b.createdAt.toISOString().split('T')[0];

      csv += `${b.id},${hotelName},${userName},${b.user.email},${checkIn},${checkOut},${b.status},${b.totalPrice},${date}\n`;
    });

    res.header('Content-Type', 'text/csv');
    res.attachment(`laporan_booking_${Date.now()}.csv`);
    return res.send(csv);

  } catch (error) {
    response(500, null, error.message, res);
  }
};

module.exports = { getDashboardStats, exportBookingsCSV };