Q      = require 'q'
router = require('express').Router()

Website = require '../models/website'
User    = require '../models/user'
Domain  = require '../models/domain'


module.exports = (app) ->
    hybridRedirect = (req, res, target) ->
        if req.xhr
            return res.json(redirect: target)
        else
            return res.redirect(target)

    hybridRender = (req, res, kwargs) ->
        if req.xhr
            return res.json
                data: kwargs.data
                template: kwargs.template
                validation: kwargs.validation
        else
            app.render kwargs.template,
                data: kwargs.data, validation: kwargs.validation,
                (err, html) ->
                    if err
                        console.error(err)
                        return res.status(500).json(error: err)
                    else
                        return res.render('layout', content: html, data: kwargs.result)

    hybridEndpoint = (req, res, kwargs) ->
        kwargs.query.exec()
        .then (result) ->
            if not result
                return res.status(404).json(error: 'no records found')
            else
                return hybridRender(req, res, data: result, template: kwargs.template)

        .then null, (err) ->
            return res.status(500).json(error: err)

    router.get '/', (req, res) ->
        if req.xhr then return res.json(template: 'index')
        else
            app.render 'index', (err, html) ->
                return res.render('layout', content: html)

    router.get '/websites', (req, res) ->
        return hybridEndpoint req, res,
            template: 'websites'
            query: Website.find().populate(['owner', 'hostname'])

    router.get '/websites/:id', (req, res) ->
        q = Website.findOne(_id: req.params.id)
            .populate(['owner', 'hostname', 'domain', 'collaborators'])

        return hybridEndpoint req, res,
            template: 'website-detail'
            query: q

    router.get '/users', (req, res) ->
        return hybridEndpoint req, res,
            template: 'users'
            query: User.find()

    router.get '/users/add', (req, res) ->
        return hybridRender req, res,
            template: 'user-detail'
            data: new User()

    router.get '/users/:id', (req, res) ->
        return hybridEndpoint req, res,
            template: 'user-detail'
            query: User.findOne(_id: req.params.id).populate('connections')

    router.post '/users/:id', (req, res) ->
        _user = undefined

        (->
            if req.params.id is 'add'
                return Q new User()
            else
                return User.findOne(_id: req.params.id).exec()
        )()
        .then (user) ->
            _user = user
            user.set req.body
            return user.save()
        .then (user) ->
            return hybridRedirect(req, res, '/users')
        .then null, (err) ->

            if err.name is 'ValidationError'
                return hybridRender( req, res, data: _user, validation: err, template: 'user-detail')
            else
                console.error(err)
                return res.status(500).json(err)

    deleteUser = (req, res) ->
        User.find( _id: req.params.id ).remove().exec()
        .then ->
            return hybridRedirect(req, res, '/users')
        .then null, (err) ->
            console.error(err)
            return res.status(500).json(err)

    router.delete '/users/:id', deleteUser
    router.get '/users/:id/delete', deleteUser

    return router
