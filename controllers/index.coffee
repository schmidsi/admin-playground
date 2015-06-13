router = require('express').Router()

Website = require '../models/website'
User    = require '../models/user'
Domain  = require '../models/domain'


module.exports = (app) ->
    hybridEndpoint = (req, res, kwargs) ->
        kwargs.query.exec()
        .then (result) ->
            if req.xhr
                return res.json(data: result)
            else
                app.render kwargs.template, data: result, (err, html) ->
                    console.log(err)
                    if err then return res.status(500).json(error: err)

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

    return router
