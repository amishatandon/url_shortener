const express = require('express');
const mongoose = require('mongoose');
const config = require('config');

const app = express();

const db = config.get('mongoURI');


mongoose.connect(db, {

})
.then(() => console.log('MongoDB connected...'))
.catch(err => {
  console.error('MongoDB connection error:', err.message);
  process.exit(1);
});

app.use(express.json());


app.use('/api/url', require('./routes/url'));

const PORT = 8080;

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
