const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const streamSchema = new Schema({
    userId: 
      {
        type: String,
        required: true,
      },
    nuggetIds:
      {
        type: [String],
      },
    currentPosition:
      {
        type: Number,
      },    
}, { timestamps: true });

module.exports = mongoose.model('Stream', streamSchema);