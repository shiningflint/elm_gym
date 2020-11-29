module Username exposing
    ( Error(..)
    , Username
    , blur
    , empty
    , errorMessage
    , input
    , toString
    )

import Html exposing (Html)
import InputField


type Username
    = Username (InputField.InputField Error)


type Error
    = LengthTooLong
    | LengthTooShort


empty : Username
empty =
    Username <| InputField.init "" validator


input : Username -> (Username -> msg) -> msg -> Html msg
input (Username inputField) onInputMsg onBlurMsg =
    InputField.input inputField (onInputMsg << Username) onBlurMsg


toString : Username -> String
toString (Username inputField) =
    InputField.toString inputField


blur : Username -> Username
blur (Username inputField) =
    Username (InputField.blur inputField)


errorMessage : Username -> String
errorMessage (Username inputField) =
    let
        errorResult =
            InputField.errorResult inputField
    in
    case errorResult of
        Ok value ->
            ""

        Err LengthTooLong ->
            "Username too long"

        Err LengthTooShort ->
            "Username too short"



-- Internals


validator : String -> Result ( String, Error ) String
validator value =
    if String.length value > 20 then
        Err ( value, LengthTooLong )

    else if String.length value < 5 then
        Err ( value, LengthTooShort )

    else
        Ok value
