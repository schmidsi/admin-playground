_ = require('lodash');

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

    var url = this.getAttribute('href');
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
        queryByHook('container')[0].innerHTML = html;
        bindAsync();
    }
    xhr.send()
}

var init = function init() {
    bindAsync();
}

document.addEventListener('DOMContentLoaded', init)
