const mongoose = require('mongoose');

const SchoolSchema = new mongoose.Schema({
  schoolName: { type: String, required: true },
  schoolAddress1: { type: String, required: true },
  schoolAddress2: { type: String, required: false },
  city: { type: String, required: true },
  state: { type: String, required: true },
  country: { type: String, required: true },
  zipCode: { type: String, required: true },
  adminFirstName: { type: String, required: true },
  adminLastName: { type: String, required: true },
  adminEmail: { type: String, required: true, unique: true }, // Assuming admin email is unique
  approvalStatus: { type: String, required: true, default: 'Pending' }
}, { timestamps: true });

module.exports = mongoose.model('School', SchoolSchema);
