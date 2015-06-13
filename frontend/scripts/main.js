var _        = require('lodash');
var Velocity = require('velocity-animate');

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
    _( queryByHook('async') ).each(function(el, i) {
        el.addEventListener('click', asyncHandler)
    });
}

var unbindAsync = function() {
    _( queryByHook('async') ).each(function(el, i) {
        el.removeEventListener('click', asyncHandler)
    });
}

var asyncHandler = function(event) {
    event.preventDefault();

    navigate( this.getAttribute('href') );
}

var navigate = function(url) {
    var xhr = new XMLHttpRequest();

    xhr.open('GET', url);
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.onload = function (e) {
        response = JSON.parse(this.responseText);
        locals = {
            data: response.data,
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
    xhr.send()
}

var init = function init() {
    bindAsync();

    window.onpopstate = function(event) {
        navigate( document.location.pathname );
    }
}

document.addEventListener('DOMContentLoaded', init)
