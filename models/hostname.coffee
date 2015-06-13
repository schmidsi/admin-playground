# Hostname Model
# ============
#
# All hostnames for quick lookup
#
# A hostname must be either a primary hostname (= website != null)
# or a redirecter (= redirectTo != null)

mongoose = require 'mongoose'
tld      = require 'tldjs'

Schema   = mongoose.Schema


hostnameSchema = new Schema
    name:
        type: String
        required: true
        unique: true
        index: true
    redirectTo:
        type: Schema.Types.ObjectId
        ref: 'Hostname'
    website:
        type: Schema.Types.ObjectId
        ref: 'Website'
    domain:
        type: Schema.Types.ObjectId
        ref: 'Domain'
        required: false


hostnameSchema.plugin require('mongoose-timestamp')

hostnameSchema.validators =
    hostname: (value) ->
        tld.tldExists(value) and tld.isValid(value)


module.exports = mongoose.model('Hostname', hostnameSchema)
