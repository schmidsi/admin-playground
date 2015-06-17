var _         = require('lodash');
//var serialize = require('form-serialize');
var Velocity  = require('velocity-animate');

// load isomorphic templates
var templates = {
    'index':          require('../templates/index.jade'),
    'websites':       require('../templates/websites.jade'),
    'website-detail': require('../templates/website-detail.jade'),
    'users':          require('../templates/users.jade'),
    'user-detail':    require('../templates/user-detail.jade')
}

var queryByHook = function(hook) {
    return document.querySelectorAll('[data-hook~=' + hook + ']');
}

var bindAsync = function() {
    _( queryByHook('async-link') ).each(function(el, i) {
        el.addEventListener('click', asyncLinkHandler)
    });

    _( queryByHook('async-form') ).each(function(el, i) {
        el.addEventListener('submit', asyncFormHandler)
    });

    _( queryByHook('async-delete') ).each(function(el, i) {
        el.addEventListener('click', asyncDeleteHandler)
    });
}

var unbindAsync = function() {
    _( queryByHook('async-link') ).each(function(el, i) {
        el.removeEventListener('click', asyncLinkHandler)
    });

    _( queryByHook('async-form') ).each(function(el, i) {
        el.removeEventListener('submit', asyncFormHandler)
    });

    _( queryByHook('async-delete') ).each(function(el, i) {
        el.removeEventListener('click', asyncDeleteHandler)
    });
}

var asyncLinkHandler = function(event) {
    event.preventDefault();

    async( this.getAttribute('href') );
}

var asyncFormHandler = function(event) {
    event.preventDefault();

    async( this.action, new FormData(this) )
}

var asyncDeleteHandler = function(event) {
    event.preventDefault();

    async( document.location.pathname, undefined, 'DELETE')
}

var async = function(url, formdata, method) {
    var xhr = new XMLHttpRequest();

    if (!method) {
        method = formdata ? 'POST' : 'GET'
    }

    xhr.open(method, url);
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.onload = function (e) {
        response = JSON.parse(this.responseText);

        if (this.status == '500') {
            return alert( response.error.message )
        }

        if (response.redirect) {
            return async(response.redirect)
        }

        locals = {
            data: response.data,
            validation: response.validation,
            moment: require('moment')
        }
        html = templates[response.template](locals);

        unbindAsync();
        container = queryByHook('container')[0];

        Velocity.animate(container, {opacity: 0, translateY: '-200px'})
        .then( function() {
            container.innerHTML = html;
            bindAsync();
            history.pushState({}, '', url);
            return Velocity.animate(container, {opacity: 1, translateY: 0})
        })
        .catch( function(err) { console.error(err) } );
    }
    xhr.send( formdata )
}


var init = function init() {
    bindAsync();

    window.onpopstate = function(event) {
        async( document.location.pathname );
    }
}

document.addEventListener('DOMContentLoaded', init)
