module Username exposing
    ( Error(..)
    , Username
    , blur
    , empty
    , input
    ,  toString
       -- , errorMessage

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



-- Internals


validator : String -> Result Error String
validator value =
    if String.length value > 20 then
        Err LengthTooLong

    else if String.length value < 5 then
        Err LengthTooShort

    else
        Ok value
