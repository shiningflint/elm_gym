module Route exposing (Route(..), parseUrl)

import Url
import Url.Parser as Parser exposing ((</>))


type Route
    = NotFound
    | Top
    | Home
    | HomeCourses
    | Courses String


parseUrl : Url.Url -> Route
parseUrl url =
    case Parser.parse routes url of
        Just route ->
            route

        Nothing ->
            NotFound



-- private


routes : Parser.Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Top Parser.top
        , Parser.map Home <| Parser.s "home"
        , Parser.map HomeCourses <| Parser.s "home" </> Parser.s "courses"
        , Parser.map Courses <| Parser.s "courses" </> Parser.string
        ]
