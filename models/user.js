const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const userSchema = new Schema({
    loginId: 
      {
        type: String,
        unique : true, 
        dropDups: true,
      },
    username: 
      {
        type: String,
        required: true,
        unique : true, 
        dropDups: true,
      },
    savedNuggetIds: 
      {
        type: [String],
      },
    seenNuggetIds: 
      {
        type: [String],
      },
    likedNuggetIds: 
      {
        type: [String],
      },
    selectedTopics: 
      {
        type: [String],
      },
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);