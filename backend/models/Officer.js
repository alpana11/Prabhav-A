const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const officerSchema = new mongoose.Schema(
  {
    officerId: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    name: { type: String },
    department: { type: String, enum: ['road', 'water', 'electricity', 'sanitation'], required: true },
    role: { type: String, default: 'officer' }
  },
  { timestamps: true }
);

officerSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

officerSchema.methods.comparePassword = async function (candidate) {
  return bcrypt.compare(candidate, this.password);
};

module.exports = mongoose.model('Officer', officerSchema);
