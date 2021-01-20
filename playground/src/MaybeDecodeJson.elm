-- learning Json decode through maybe
-- refer to this awesome blog
-- https://thoughtbot.com/blog/getting-unstuck-with-elm-json-decoders


module MaybeDecodeJson exposing (User, ageDecoder, createUserMap, maybeAge, maybeName, nameDecoder, userDecoder)

import Json.Decode as D exposing (Decoder)


type alias User =
    { name : String
    , age : Int
    }


maybeName : Maybe String
maybeName =
    Just "Bambang Santoso"


maybeAge : Maybe Int
maybeAge =
    Just 45


createUserMap : Maybe User
createUserMap =
    Maybe.map2 User maybeName maybeAge


nameDecoder : Decoder String
nameDecoder =
    D.field "name" D.string


ageDecoder : Decoder Int
ageDecoder =
    D.field "age" D.int



-- example decode
-- D.decodeString userDecoder """{ "name": "Bambang", "age": 32 }"""


userDecoder : Decoder User
userDecoder =
    D.map2 User nameDecoder ageDecoder
