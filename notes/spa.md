# Elm SPA Development

I want to write about:
- Browser.application
- How to use a http server for spa to redirect all routes
- Route module for handling all routes

## Browser.application
Elm SPA requires the `Browser.application` function to handle full SPA features:
- URL changes
- URL redirects
- Full control of title and body contents

## Handling Routes
Usually on production you want to configure route redirection, wether it's in an Nginx configuration, or any route handling services you use (e.g. AWS route 51).

But on development, there is an npm package called `live-server`. Where it has an option to redirect everything back to a file (usually `index.html`). From there, you let your elm app to catch the URL and handle the proper page rendering.

## Elm Route module
In your elm app, you create your Route module. But based on the `elm-spa-example`, you define all the route types over there and then expose them. They're not opaque.


Next question to figure out:
1. How do you set the route based on URL.
2. How to determine the page to render based on route change.
