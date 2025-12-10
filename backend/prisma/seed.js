const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Memulai Seeding...');

  // 1. HASH PASSWORD
  const hashedPasswordAdmin = await bcrypt.hash('admin123', 10);
  const hashedPasswordUser = await bcrypt.hash('user123', 10);

  // 2. BUAT USER ADMIN & CUSTOMER
  const admin = await prisma.user.upsert({
    where: { email: 'admin@hotel.com' },
    update: {},
    create: {
      email: 'admin@hotel.com',
      name: 'Super Admin',
      password: hashedPasswordAdmin,
      role: 'ADMIN',
    },
  });

  const user = await prisma.user.upsert({
    where: { email: 'user@test.com' },
    update: {},
    create: {
      email: 'user@test.com',
      name: 'Customer Demo',
      password: hashedPasswordUser,
      role: 'USER',
    },
  });

  console.log('✅ User created/checked');

  // 3. BUAT HOTEL
  const existingHotel = await prisma.hotel.findFirst({
    where: { name: 'Hotel Grand Menteng' }
  });

  let hotel;
  if (!existingHotel) {
    hotel = await prisma.hotel.create({
      data: {
        name: 'Hotel Grand Menteng',
        address: 'Jl. Matraman Raya No. 21, Jakarta',
        description: 'Hotel nyaman di pusat kota dengan akses mudah ke mana saja.',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop', 
        rating: 4.5,
        rooms: {
          create: [
            {
              type: 'Deluxe Room',
              price: 500000,
              capacity: 2,
              isAvailable: true,
              imageUrl: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=1000&auto=format&fit=crop'
            },
            {
              type: 'Family Suite',
              price: 1200000,
              capacity: 4,
              isAvailable: true,
              imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1000&auto=format&fit=crop'
            },
          ],
        },
      },
    });
    console.log('✅ Hotel & Rooms created');
  } else {
    console.log('ℹ️ Hotel already exists, skipping...');
  }

  console.log('🚀 Seeding selesai!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });