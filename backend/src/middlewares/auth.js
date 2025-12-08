const jwt = require('jsonwebtoken');
const response = require('../utils/response');

const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return response(401, null, "Access Denied", res);

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET || 'secretkey');
    req.user = verified;
    next();
  } catch (error) {
    return response(403, null, "Invalid Token", res);
  }
};

const checkRole = (role) => {
  return (req, res, next) => {
    if (req.user.role !== role) {
      return response(403, null, `Access denied. You are not an ${role}`, res);
    }
    next();
  };
};

module.exports = { verifyToken, checkRole };