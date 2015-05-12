express  = require 'express'
moment   = require 'moment'

PORT        = process.env.PORT || 3000


app = express()
app.set 'port', PORT

app.use(express.static(__dirname + '/dist'));
app.set 'view engine', 'jade'
app.set 'views', __dirname + '/frontend/templates'

app.locals.moment = moment

# Until the image optimisation process isn't implemented, hack it like this:
app.use '/img', express.static(__dirname + '/frontend/images')

# make node_modules accessible
app.use '/lib', express.static(__dirname + '/node_modules/')

app.get '/', (req, res) ->
    res.render 'index'

app.get '/websites', (req, res) ->
    return res.render 'websites',
        websites: [
            {
                hostname: 'www.nutters.ch'
                owner: 'Marco Müller'
                created: moment('2014-12-24T16:23:42.724Z')
            }
            {
                hostname: 'www.wyla.ch'
                owner: 'Marco Müller'
                created: moment('2014-12-24T16:23:42.724Z')
            }
            {
                hostname: 'www.djredshift.ch'
                owner: 'Marco Müller'
                created: moment('2014-12-24T16:23:42.724Z')
            }
            {
                hostname: 'www.simonkwe.com'
                owner: 'Marco Müller'
                created: moment('2014-12-24T16:23:42.724Z')
            }
        ]

app.get '/websites/:id', (req, res) ->
    return res.render 'website-detail',
        hostname: 'www.nutters.ch'
        owner: 'Marco Müller'
        created: moment('2014-12-24T16:23:42.724Z')
        updated: moment('2015-03-12T14:04:52.724Z')
        collaborators: [
            'Michaela Neckler'
            'Cornelius Pfau'
        ]
        hostnames: [
            'nutters.ch'
            'nutters.onescreener.com'
        ]
        domain: 'nutters.ch'

app.get '/users', (req, res) ->
    return res.render 'users',
        users: [
            {
                name: 'Marco Müller'
                email: 'marco.muller@example.com'
                created: moment('2014-12-24T16:23:42.724Z')
            }
            {
                name: 'Michaela Neckler'
                email: 'michaela.neckler@example.com'
                created: moment('2014-12-24T16:23:42.724Z')
            }
            {
                name: 'Cornelius Pfau'
                email: 'cornelius.pfau@example.com'
                created: moment('2014-12-24T16:23:42.724Z')
            }
            {
                name: 'Dragan Strebel'
                email: 'dragan.strebel@example.com'
                created: moment('2014-12-24T16:23:42.724Z')
            }
            {
                name: 'Monika Laugenstein'
                email: 'monika.laugenstein@example.com'
                created: moment('2014-12-24T16:23:42.724Z')
            }
        ]

app.get '/users/:1', (req, res) ->
    return res.render 'user-detail',
        name: 'Marco Müller'
        email: 'marco.muller@example.com'
        created: moment('2014-12-24T16:23:42.724Z')
        updated: moment('2015-03-12T14:04:52.724Z')
        websites: [
            {
                hostname: 'www.nutters.ch'
                role: 'owner'
            }
            {
                hostname: 'www.simonkwe.com'
                role: 'collaborator'
            }
        ]
        connections: [
            {
                network: 'facebook'
                id: '4'
            }
        ]

if not module.parent
    app.listen app.get('port')
    console.log '\n' + 'Server started and listening on port:' + app.get('port')

module.exports = app
