mongoose = require 'mongoose'

Q        = require 'q'
User     = require '../models/user'
Domain   = require '../models/domain'
Hostname = require '../models/hostname'
Website  = require '../models/website'

MONGO_URI   = process.env.MONGO_URI ||
              process.env.MONGOLAB_URI ||
              'mongodb://localhost/admin-playground'


Q.nbind(mongoose.connect, mongoose)(MONGO_URI)
.then ->
    mongoose.connection.db.dropDatabase()
.then ->
    u1 = new User
        name: 'Marco Müller'
        email: 'marco.muller@example.com'
        password: 'asdf'
        verified: new Date()
    u1.save()

.then ->
    u2 = new User
        name: 'Michaela Neckler'
        email: 'michaela.neckler@example.com'
        password: 'qwer'
        verified: new Date()
    u2.save()

.then ->
    u3 = new User
        name: 'Cornelius Pfau'
        email: 'cornelius.pfau@example.com'
    u3.save()

.then ->
    User.oAuthQ
        profile:
            id: 1
            provider: 'facebook'
            displayName: 'Dragan Strebel'
            emails: [value: 'dragan.strebel@example.com']

.then ->
    User.oAuthQ
        profile:
            id: 2
            provider: 'google'
            displayName: 'Monika Laugenstein'
            emails: [value: 'monika.laugenstein@example.com']

.then ->
    console.log 'all users created'

.then null, (err) ->
    console.log err


