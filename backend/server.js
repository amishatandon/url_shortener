const express = require('express');
const mongoose = require('mongoose');
const config = require('config');

const app = express();

// MongoDB URI from config
const db = config.get('mongoURI');

// Connect to MongoDB
mongoose.connect(db, {

})
.then(() => console.log('MongoDB connected...'))
.catch(err => {
  console.error('MongoDB connection error:', err.message);
  process.exit(1);
});

app.use(express.json());

// Routes
app.use('/api/url', require('./routes/url'));

const PORT = 8080;

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
