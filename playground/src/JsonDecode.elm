module JsonDecode exposing
    ( decodedGoodResult
    , decodedNullResult
    , goodResult
    , nullResult
    , spitNumbers
    )

import Json.Decode exposing (..)


nullResult : String
nullResult =
    """{ "numbers": null}"""


goodResult : String
goodResult =
    """{ "numbers": [1,5,10,11]}"""


spitNumbers : Result Error (Maybe a) -> String
spitNumbers result =
    case result of
        Ok Nothing ->
            "Numbers got nothing"

        Ok (Just numbers) ->
            "Got numbers " ++ toString numbers

        Err _ ->
            "Got error"


decodedGoodResult =
    decodeString (field "numbers" (nullable (list int))) goodResult


decodedNullResult =
    decodeString (field "numbers" (nullable (list int))) nullResult
