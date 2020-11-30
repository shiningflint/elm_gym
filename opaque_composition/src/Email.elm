module Email exposing (Email, blur, empty, errorMessage, input, toString)

import Html exposing (Html)
import InputField


type Email
    = Email (InputField.InputField Error)


type Error
    = IncorrectFormat


input : Email -> (Email -> msg) -> msg -> Html msg
input (Email inputField) onInputMsg onBlurMsg =
    InputField.input inputField (onInputMsg << Email) onBlurMsg


blur : Email -> Email
blur (Email inputField) =
    Email (InputField.blur inputField)


empty : Email
empty =
    Email <| InputField.init "" validator


toString : Email -> String
toString (Email inputField) =
    InputField.toString inputField


errorMessage : Email -> String
errorMessage (Email inputField) =
    let
        errorResult =
            InputField.errorResult inputField
    in
    case errorResult of
        Ok value ->
            ""

        Err IncorrectFormat ->
            "Email format is incorrect"



-- Internals


validator : String -> Result ( String, Error ) String
validator value =
    if String.length value < 5 then
        Err ( value, IncorrectFormat )

    else
        Ok value
