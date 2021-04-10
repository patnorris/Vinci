const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const nuggetSchema = new Schema({
    creatorId: 
      {
        type: String,
      },
    nuggetType:
      {
        type: String,
      },
    content:
      {
        type: String,
      },
    source:
      {
        type: String,
      },
    topics: 
      {
        type: [String],
      },
}, { timestamps: true });

module.exports = mongoose.model('Nugget', nuggetSchema);