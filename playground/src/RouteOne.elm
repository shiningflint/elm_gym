module RouteOne exposing (Route(..), toRoute)

import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


type Route
    = NotFound
    | Home
    | Posts


routeList : Parser (Route -> a) a
routeList =
    oneOf
        [ map Home top
        , map Posts (s "posts")
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFound (parse routeList url)
