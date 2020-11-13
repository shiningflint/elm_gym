# JS Interop

## Sending data to JS
Pay attention to the keyword `port`
`port yourPortFunctionName  : String -> Cmd msg`
It just sends one parameter, just sends one message.

Also remember to set the module as a port
`port module MyModule exposing (main)`


Basic syntax in the JS side is just
`app.ports.[port function name].send`
`app.ports.[port function name].receive`
It's using the basic publish and subscribe model between elm & JS.
