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

## Reusing views
This [Reddit post](https://www.reddit.com/r/elm/comments/cqd93z/two_ways_to_reuse_views_which_do_i_choose/) asks about how to reuse elm views.
Using Cmd.map & Http.map (Composing to mini elm apps) is highly discouraged. While you do need to use them as part of scaling elm apps, many people tried abusing it.

The question:
> It seems as though there are two main ways to create a reusable view which has some internal state.
The first is to make it a mini elm app. I.e. Model, Msg, init, view, update. The caller then uses Html.map, Cmd.map and so on.  
The second is like [elm-sortable-table](https://package.elm-lang.org/packages/NoRedInk/elm-sortable-table/latest/) which exposes a State, init, view. The view is more or less something like:
`view : (State -> msg) -> OtherConfigValues -> State -> Html msg`
Which is the better of these approaches? Is there a situation where I should use one over the other?

One good answer:
> The first one brings in way more complexity.  
I can have an entire module of small reusable views implemented with the second approach BUT, the first approach would mandate one module per component.  
So, simple functions for views without state, this second approach for views that have to have some state in them and use the first approach only as the last resort. This usually happens if I need side-effects in the update of the component.  
Let say that I have a complex Sidebar. If it doesn't generate events, I just have a function. If I have a search bar in the Sidebar then I use a function with state (second approach). If I have a ticker that pulls data from some service (i.e. requires http calls), then I might create a Sidebar.elm with Model, Msg, init, view, update.

Extra read
https://www.freecodecamp.org/news/scaling-elm-views-with-master-view-types/
