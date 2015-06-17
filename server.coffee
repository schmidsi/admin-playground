express  = require 'express'
moment   = require 'moment'
mongoose = require 'mongoose'

MONGO_URI   = process.env.MONGO_URI ||
              process.env.MONGOLAB_URI ||
              'mongodb://localhost/admin-playground'
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

app.use require('body-parser').urlencoded(extended: true)
app.use require('multer')(dest: './uploads/')
app.use require('cookie-parser')()
app.use require('cookie-session')(secret: process.env.SECRET || 'INSECURE!!!')
app.use require('flash')()

app.use require('./controllers')(app)

if not module.parent
    mongoose.connect(MONGO_URI)
    app.listen app.get('port')
    console.log '\n' + 'Server started and listening on port:' + app.get('port')

module.exports = app
