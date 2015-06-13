# Website Model
# =============

Q         = require 'q'
mongoose  = require 'mongoose'
validator = require 'validator'

Schema    = mongoose.Schema

Hostname  = require './hostname'


websiteSchema = new Schema
    template: String
    data: Object
    owner:
        type: Schema.Types.ObjectId
        ref: 'User'
    collaborators:
        [
            type: Schema.Types.ObjectId
            ref: 'User'
        ]
    hostname:
        type: Schema.Types.ObjectId
        ref: 'Hostname'
    linkedDomain:
        type: Schema.Types.ObjectId
        ref: 'Domain'


websiteSchema.plugin require('mongoose-timestamp')


# create a new hostname and associate it with the homepage
websiteSchema.methods.deploy = (hostname, callback) ->
    Hostname.register hostname, @, (err, hostnameInstance) =>
        if hostnameInstance && @hostname != hostnameInstance._id
            @hostname = hostnameInstance
            @save (err) ->
                return callback(err, hostnameInstance)
        else
            return callback(err, hostnameInstance)

websiteSchema.methods.deployQ = (hostname) ->
    Q.nbind( @deploy, @ )( hostname )

# ensure that there is only one hostname pointing to this website
websiteSchema.pre 'save', (next) ->
    if @hostname == undefined then return next()

    @populate 'hostname', (err, website) =>
        if website.hostname
            redirectHostnamesQuery = Hostname.find( $and: [
                { website: @ },
                { _id: { $ne: website.hostname._id } }
            ])

            Hostname.update(
                redirectHostnamesQuery,
                { website: null, redirectTo: website.hostname.name },
                { multi: true } )
            .exec (err, numberAffected) ->
                next(err)
        else
            next()


module.exports = mongoose.model('Website', websiteSchema)
