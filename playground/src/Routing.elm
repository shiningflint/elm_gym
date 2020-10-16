module Routing exposing (Route(..), toRoute)

import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


type Route
    = NotFound
    | Home
    | Posts
    | Post Int
    | PostEdit Int
    | PostNew


routeList : Parser (Route -> a) a
routeList =
    oneOf
        [ map Home top
        , map Posts (s "posts")
        , map Post (s "posts" </> int)
        , map PostEdit (s "posts" </> int </> s "edit")
        , map PostNew (s "posts" </> s "new")
        ]


toRoute : String -> Route
toRoute string =
    case Url.fromString string of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound (parse routeList url)
