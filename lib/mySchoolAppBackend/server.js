const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const nodemailer = require('nodemailer');

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
//      approvalStatus: "Pending"
});

// Configure Nodemailer transporter
coconst transporter = nodemailer.createTransport({
    host: 'smtp.mailgun.org',
    port: 587,
    secure: false, // true for 465, false for other ports
    auth: {
          user: 'postmaster@sandboxa0c3ba5b023e4ebcb2e9f8e201876ba1.mailgun.org', // Your SMTP username
      pass: 'f114c7280f4829b4c4cc9bebac77cc23-309b0ef4-fd4fb634' // Your SMTP password
    }
  });


const School = mongoose.model('School', SchoolSchema);

app.post('/registerSchool', async (req, res) => {
  try {
    const school = new School(req.body);
    await school.save();

    // Send email using custom SMTP server
    const mailOptions = {
      from: 'unichat.team@gmail.com', // Email address of the sender
      to: req.body.adminEmailAddress, // Use the admin's email from the request body
      subject: 'School Registration Confirmation',
      text: `Dear ${req.body.adminFirstName},\n\nYour school "${req.body.schoolName}" has been successfully registered.`, // Text body
      // You can also use `html` key for HTML body
    };

    transporter.sendMail(mailOptions, function(error, info){
      if (error) {
        console.log(error);
        res.status(500).send('Error sending email: ' + error.message);
      } else {
        console.log('Email sent: ' + info.response);
        res.status(200).json({ message: 'School registered successfully and email sent', info: info.response });
      }
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: 'Failed to register school', error: error.message });
  }
});


app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});