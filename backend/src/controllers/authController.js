// src/controllers/authController.js
const prisma = require('../config/db'); // Mengambil dari file db.js yang sudah Anda buat
const response = require('../utils/response');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const register = async (req, res) => {
  const { name, email, password, role } = req.body;

  try {
    // Cek email duplikat
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return response(400, null, "Email already registered", res);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
        role: role || "customer"
      }
    });

    response(201, { id: user.id, name: user.name, email: user.email }, "Register success", res);
  } catch (error) {
    console.error(error);
    response(500, null, "Internal Server Error", res);
  }
};

const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await prisma.user.findUnique({ where: { email } });
    
    if (!user) return response(404, null, "User not found", res);

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return response(401, null, "Invalid credentials", res);

    // Buat Token JWT
    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET || 'secretkey', {
      expiresIn: '1d'
    });

    response(200, { token, role: user.role }, "Login success", res);
  } catch (error) {
    console.error(error);
    response(500, null, "Internal Server Error", res);
  }
};

module.exports = { register, login };