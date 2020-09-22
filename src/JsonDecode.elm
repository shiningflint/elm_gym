module JsonDecode exposing
    ( goodResult
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
        Ok r ->
            case r of
                Nothing ->
                    "Numbers got nothing"

                Just numbers ->
                    "Got numbers"

        Err _ ->
            "Got error"



-- spitNumbers ((decodeString (field "numbers" (nullable (list int)))) nullResult)
-- spitNumbers ((decodeString (field "numbers" (nullable (list int)))) goodResult)
