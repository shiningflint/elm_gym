# Elm Modules

elm guide
https://guide.elm-lang.org/webapps/modules.html

> Elm modules work best when you define them around a central type. Like how the `List` module is all about the `List` type.

## Exposing variants of a custom type

Refer to this error when exposing variants of a custom type:

```
It looks like you are trying to expose the variants of a custom type:

1| module Doc exposing (Banana(Potato), greetings)

You need to write something like Status(..) or Entity(..) though. It is all or
nothing, otherwise `case` expressions could miss a variant and crash!

Note: It is often best to keep the variants hidden! If someone pattern matches
on the variants, it is a MAJOR change if any new variants are added. Suddenly
their `case` expressions do not cover all variants! So if you do not need people
to pattern match, keep the variants hidden and expose functions to construct
values of this type. This way you can add new variants as a MINOR change!
```
