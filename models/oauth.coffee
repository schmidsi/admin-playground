# OAuth Model
# -----------
#
# Holds oAuth Connections. Facebook, Soundcloud, ...
# Every User can have one or more providers. Even multiple connections
# to the same provider are possible.

Mongoose = require 'mongoose'

Schema   = Mongoose.Schema

PROVIDERS = [
    'facebook'
    'google'
    'soundcloud'
    'twitter'
    'instagram'
    'testprovider'
]


connectionSchema = new Schema
    # The paresed profile [passport.js User Profile]
    # inclusive the raw json as profile._json
    profile: {
        # The provider string
        # according to [passport.js User Profile]
        provider:
            required: true
            type: String
            enum: PROVIDERS

        # The provider specific id
        id:
            type: String
            required: true

        displayName: String
        profileUrl: String
        name: {}
        emails: {}
        photos: {}

        # json dump of provider answer
        _json: {}
    }

    user:
        type: Schema.Types.ObjectId
        ref: 'User'
        index: true


connectionSchema.index 'profile.provider': 1, 'profile.id': 1

connectionSchema.plugin require('mongoose-timestamp')


module.exports = Mongoose.model('Connection', connectionSchema)
module.exports.PROVIDERS = PROVIDERS
