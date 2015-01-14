# Overview

Devops Webapp is a web interface for Devops Service. It is a Backbone/Marionete web application with Sinatra backend.

## Sinatra app

Sinatra is used to serve static files and perform "quick" requests for Devops Service. Currently it uses Thin as a server. Run it with
``
rackup config.ru
``
