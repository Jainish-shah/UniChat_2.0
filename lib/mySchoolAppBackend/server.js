const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

mongoose.connect('mongodb+srv://UniChat:Unichat.25@unichat.gvnwowz.mongodb.net/?retryWrites=true&w=majority&appName=Unichat/registerSchool', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB...'))
  .catch(err => console.error('Could not connect to MongoDB...', err));

const SchoolSchema = new mongoose.Schema({
  schoolName: String,
  schoolAddressLine1: String,
  schoolAddressLine2: String,
  city: String,
  state: String,
  country: String,
  zipCode: String,
  adminFirstName: String,
  adminLastName: String,
  adminEmailAddress: String,
});

const School = mongoose.model('School', SchoolSchema);

app.post('/registerSchool', async (req, res) => {
  try {
    const school = new School(req.body);
    await school.save();
    res.send('School registered successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
