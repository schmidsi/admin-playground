# User Model
# ==========
#
# All registered users.
# Email/Password

Q          = require 'q'
_          = require 'lodash'
bcrypt     = require 'bcrypt'
Mongoose   = require 'mongoose'

Schema     = Mongoose.Schema

OAuthModel = require './oauth'

OAUTH_FUNCTIONS_DEFAULT_ARGS =
    profile:
        provider: undefined # required
        id: undefined # required


userSchema = new Schema
    name: String
    email:
        type: String
        index: true
        unique: true
        sparse: true
    password:
        type: String
        select: false
        set: (newValue) ->
            return bcrypt.hashSync(newValue, 10)
    verified: Date
    lastLogin: Date
    connections: [{ type: Schema.Types.ObjectId, ref: 'Connection' }]


userSchema.plugin require('mongoose-timestamp')
userSchema.plugin require('mongoose-unique-validator')


userSchema.methods.verify = (callback) ->
    @verified = new Date
    @save callback

# User Level oAuth Function:
# Look for the connection in the user
# - found: update oauth profile
# - not found: create new connection
#
# -> return user via callback
userSchema.methods.oAuth = (args, callback) ->
    options  = _.defaults(args, OAUTH_FUNCTIONS_DEFAULT_ARGS)
    profile  = options.profile

    # check if the requested provider/id already exists
    OAuthModel.findOne
        'profile.provider': profile.provider,
        'profile.id': profile.id
        (err, connection) =>
            if err then callback(err)

            # there is a connection with this provider/id combo
            if connection

                # check if the existion connection belongs to another user
                if connection.user.toString() != @_id.toString()
                    callback new Mongoose.Document.ValidationError(
                        'Duplicate provider')
                else
                    connection.update options, (err) =>
                        if err then callback(err)
                        else @populate( 'connections', callback )

            # new connection
            else
                connection = new OAuthModel(options)
                connection.user = @
                @connections.push( connection )
                @save (err) =>
                    if err then return callback(err)
                    connection.save (err) =>
                        if err then return callback(err)
                        else callback(null, @)


userSchema.statics.findOneByProvider = (provider, id, callback) ->
    OAuthModel.findOne
        'profile.provider': provider,
        'profile.id': id
        (err, connection) =>
            if err then callback(err)
            else if connection
                @findById( connection.user )
                .populate( 'connections')
                .exec( callback )
            else callback(null, null)


# Collection Level oAuth Function:
# Searches for a User with the corresponding oAuth creds.
# - found: update oauth profile
# - not found: create new user
#
# -> return the created/updated user via callback
userSchema.statics.oAuth = (args, callback) ->
    options = _.defaults(args, OAUTH_FUNCTIONS_DEFAULT_ARGS)
    profile = options.profile

    @findOneByProvider profile.provider, profile.id, (err, user) =>
        if err then return callback(err)

        user ?= new @()

        if not user.email and profile.emails
            user.email = profile.emails[0].value
            user.name = profile.displayName

        user.oAuth( options, callback )

userSchema.statics.oAuthQ = (args) ->
    Q.nbind( @oAuth, @ )( args )

userSchema.statics.authenticate = (email, password, callback) ->
    @findOne email: email, (error, user) ->
        if error then return callback error
        else if user and not user.password
            callback(null, false, message:
                'User without password (only oAuth)')
        else if user and bcrypt.compareSync(password, user.password)
            callback(null, user)
        else if (user)
            callback(null, false, message: 'Incorrect password')
        else # not user
            callback(null, false, message: 'Incorrect username')


userSchema.statics.findOrCreate = (params, callback) ->
    @findOne params, (error, user) =>
        if error then callback(error)
        else if user then callback(null, user)
        else callback(null, new@(params))


module.exports = Mongoose.model('User', userSchema)
