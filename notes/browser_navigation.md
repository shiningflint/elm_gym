# Elm SPA with `Browser.Navigation`

I want to talk about `Browser.application`.
This package is used for creating a full SPA JS web app. It knows the presence of URL on the address bar and intercepting it. It is basically Vue app with vue-route feature added to it.
https://guide.elm-lang.org/webapps/navigation.html

Building an SPA in elm means you need to control the browser's navigation. The package is `Browser.Navigation`. It has cool features as:
- `pushUrl` - Adding a new entry to browser history
- `replaceUrl` - Replace current URL, useful for param changes like search
- `back` - History back
- `forward` - History forward

All those navigation features above need a navigation `key`.
According to the note in the bottom part of https://guide.elm-lang.org/webapps/navigation.html, without the key it might introduce a lot of bugs if the browser navigation is being shared outside. Adding the key into the model helps everyone avoid a subtle category of problems.

The Model type needs to store url, it will store it during `Browser.application` initialization process. And then updated everytime `Browser.Navigation` happens.

You set the messagee `onUrlRequest` with `LinkClicked`. In the update, the `LinkClicked` handler will trigger `UrlChanged` message, updating the model's url value.
