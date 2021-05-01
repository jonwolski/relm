var serverFactory = require('spa-server');

var matcher = new RegExp('elm\\.js$');

var server = serverFactory.create({
  path: '.',
  port: 8080,
  fallback: function (request, response) {
    if (matcher.test(request.url)) {
      return '/elm.js';
    } else {
      return '/index.html';
    }
  }
});

server.start();
