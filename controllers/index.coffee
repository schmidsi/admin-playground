router = require('express').Router()

Website = require '../models/website'
User    = require '../models/user'
Domain  = require '../models/domain'


module.exports = (app) ->
    hybridEndpoint = (req, res, kwargs) ->
        kwargs.query.exec()
        .then (result) ->
            if not result
                return res.status(404).json(error: 'no records found')
            else if req.xhr
                return res.json(data: result)
            else
                app.render kwargs.template, data: result, (err, html) ->
                    if err
                        console.error(err)
                        return res.status(500).json(error: err)

                    return res.render('layout', content: html, data: result)

        .then null, (err) ->
            return res.status(500).json(error: err)


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

    router.get '/users/:id', (req, res) ->
        return hybridEndpoint req, res,
            template: 'user-detail'
            query: User.findOne(_id: req.params.id).populate('connections')


    return router
