# Hostname Model
# ============
#
# All hostnames for quick lookup
#
# A hostname must be either a primary hostname (= website != null)
# or a redirecter (= redirectTo != null)

_        = require 'lodash'
Q        = require 'q'
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

hostnameSchema.methods.isSubdomain = ->
    return @name.indexOf('onescreener.com') > 0 or @name.indexOf('optune.me') > 0

# if hostname comes as apex (=domain without www): a www. subdomain is created
# and the apex will be redirected
# otherwise only the given hostname will be registered
hostnameSchema.statics.register = (hostname, website, callback) ->
    if not hostnameSchema.validators.hostname(hostname)
        return callback(new Error('Hostname not valid'))

    isDomain = tld.getDomain(hostname) == hostname
    result = undefined

    # if the given hostname is a domain (apex) -> create a www subdomain
    if isDomain
        domain = hostname
        hostname = 'www.' + hostname

    @findOrCreate(name: hostname)
    .then (hostnameInstance) ->
        # create primary hostname
        if hostnameInstance.isNew
            hostnameInstance.website = website.id
            result = hostnameInstance
            return hostnameInstance.save()
        else if hostnameInstance.website and hostnameInstance.website.equals(website._id)
            return result = hostnameInstance
        else
            throw new Error('hostname already exists: ' + hostname)

    .then =>
        # create a redirect from apex to www subdomain
        if isDomain
            return @findOrCreate(name: domain).then (hostnameDomainInstance) ->

                if hostnameDomainInstance.isNew
                    hostnameDomainInstance.redirectTo = result.id
                    return hostnameDomainInstance.save()
                else if hostnameDomainInstance.redirectTo == result.id
                    return true
                else
                    throw new Error('hostname already exists: ' + hostname)
        else
            return true

    .then ->
        callback(null, result)
    .then null, (err) ->
        callback(err, null)
    .end()


hostnameSchema.statics.findOrCreate = (params) ->
    @findOne(params).exec().then (hostname) =>
        if hostname then return hostname
        else return new@(params)



module.exports = mongoose.model('Hostname', hostnameSchema)
