# Domain Model
# ============
#
# This model holds all managed domains. Domains are indexed and
# have a reference to their corresponding website.


mongoose = require 'mongoose'
tld      = require 'tldjs'

Schema   = mongoose.Schema



validators =
    name:
        validator: (value) ->
            return tld.getDomain(value) == value
        msg: 'Invalid domain name'

transformations =
    # domain will be null, if tld.getDomain cant generate a domain from value
    # this will throw an error in the validation phase
    name: (value) ->
        domain = tld.getDomain(value)
        return if domain then domain else value


domainSchema = new Schema
    name:
        type: String
        index: true
        validate: validators.name
        set: transformations.name
    owner:
        type: Schema.Types.ObjectId
        ref: 'User'

domainSchema.plugin require('mongoose-timestamp')


module.exports = mongoose.model 'Domain', domainSchema
