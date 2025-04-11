const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true
    },
    password: {
        type: String,
        required: true,
        minlength: 6
    },
    preferences: {
        defaultNavigation: {
            avoidHighways: { type: Boolean, default: false },
            avoidTolls: { type: Boolean, default: false },
            preferredLanePosition: { type: String, enum: ['left', 'middle', 'right'], default: 'middle' }
        },
        notifications: {
            voice: { type: Boolean, default: true },
            vibration: { type: Boolean, default: true }
        }
    },
    savedRoutes: [{
        startLocation: {
            latitude: Number,
            longitude: Number,
            name: String
        },
        endLocation: {
            latitude: Number,
            longitude: Number,
            name: String
        },
        frequentlyUsed: { type: Boolean, default: false },
        lastUsed: Date
    }],
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Hash password before saving
userSchema.pre('save', async function(next) {
    if (this.isModified('password')) {
        this.password = await bcrypt.hash(this.password, 8);
    }
    next();
});

// Method to validate password
userSchema.methods.validatePassword = async function(password) {
    return bcrypt.compare(password, this.password);
};

// Remove sensitive data before sending to client
userSchema.methods.toJSON = function() {
    const user = this.toObject();
    delete user.password;
    return user;
};

module.exports = mongoose.model('User', userSchema);
