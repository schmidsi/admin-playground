mongoose = require 'mongoose'

Q        = require 'q'
User     = require '../models/user'
Domain   = require '../models/domain'
Hostname = require '../models/hostname'
Website  = require '../models/website'

MONGO_URI   = process.env.MONGO_URI ||
              process.env.MONGOLAB_URI ||
              'mongodb://localhost/admin-playground'

users    = []
websites = []


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
    users.push(u1)

.then ->
    u2 = new User
        name: 'Michaela Neckler'
        email: 'michaela.neckler@example.com'
        password: 'qwer'
        verified: new Date()
    u2.save()
    users.push(u2)

.then ->
    u3 = new User
        name: 'Cornelius Pfau'
        email: 'cornelius.pfau@example.com'
    u3.save()
    users.push(u3)

.then ->
    User.oAuthQ
        profile:
            id: 1049738677
            provider: 'facebook'
            displayName: 'Dragan Strebel'
            emails: [value: 'dragan.strebel@example.com']

.then (user) ->
    users.push(user)

    User.oAuthQ
        profile:
            id: 4
            provider: 'facebook'
            displayName: 'Monika Laugenstein'
            emails: [value: 'monika.laugenstein@example.com']

.then (user) ->
    users.push(user)
    console.log 'all users created'

.then ->
    website = new Website
        owner: users[0].id
        collaborators: [ users[1].id, users[2].id ]
        data:
            title: 'Super website'

    websites.push website
    website.deployQ('www.nutters.ch')

.then (hostname) ->
    domain = new Domain
        name: 'nutters.ch'
        owner: users[0].id

    hostname.domain = domain.id
    websites[0].domain = domain.id

    Q.all([ hostname.save(), websites[0].save(), domain.save() ])

.then ->
    website = new Website
        owner: users[1].id
        collaborators: [ users[3].id ]
        data:
            title: 'Idiotic website'

    websites.push website
    website.deployQ('www.djredshift.ch')

.then (hostname) ->
    domain = new Domain
        name: 'djredshift.ch'
        owner: users[1].id

    hostname.domain = domain.id
    websites[1].domain = domain.id

    Q.all([ hostname.save(), websites[1].save(), domain.save() ])

.then ->
    website = new Website
        owner: users[2].id
        collaborators: [ users[0].id, users[4].id, users[3].id ]
        data:
            title: 'Zuviele Köche verderben den Brei'

    websites.push website
    website.deployQ('www.cookbrei.ch')

.then (hostname) ->
    domain = new Domain
        name: 'cookbrei.ch'
        owner: users[2].id

    hostname.domain = domain.id
    websites[2].domain = domain.id

    Q.all([ hostname.save(), websites[2].save(), domain.save() ])

.then ->
    website = new Website
        owner: users[3].id
        collaborators: [ users[4].id ]
        data:
            title: 'Habe kein Geld für eine eigene Domain'

    websites.push website
    website.deployQ('sub.onescreener.com')

.then ->
    website = new Website
        owner: users[4].id
        collaborators: [ users[3].id ]
        data:
            title: 'Ich auch nicht'

    websites.push website
    website.deployQ('sub2.onescreener.com')

.then ->
    console.log 'finised creating dummy data'
    mongoose.connection.close()

.then null, (err) ->
    console.log err
    throw err
.done()

