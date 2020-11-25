-- This part is stuff related to the User


module Username exposing
    ( Error(..)
    , Username
    , blur
    , empty
    , error
    , errorMessage
    , input
    , setPartial
    )

import Browser
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onBlur, onInput)


type Username
    = Partial String
    | Valid String
    | Invalid String Error


type Error
    = LengthTooLong
    | LengthTooShort


empty : Username
empty =
    Partial ""


setPartial value =
    Partial value


error : Username -> Maybe Error
error username =
    case username of
        Invalid _ err ->
            Just err

        _ ->
            Nothing


input : Username -> (Username -> msg) -> msg -> Html msg
input username onInputMsg onBlurMsg =
    let
        onInputHandler =
            \value ->
                onInputMsg <|
                    case username of
                        Partial _ ->
                            Partial value

                        _ ->
                            validate value
    in
    Html.input
        [ type_ "text"
        , value <| toString username
        , onInput onInputHandler
        , onBlur onBlurMsg
        ]
        []


blur : Username -> Username
blur username =
    validate <| toString username



-- Internals


toString : Username -> String
toString username =
    case username of
        Partial string ->
            string

        Valid string ->
            string

        Invalid string _ ->
            string


validate : String -> Username
validate value =
    if String.length value > 20 then
        Invalid value LengthTooLong

    else if String.length value < 5 then
        Invalid value LengthTooShort

    else
        Valid value


errorMessage : Username -> String
errorMessage username =
    case username of
        Invalid _ LengthTooLong ->
            "Username is too long"

        Invalid _ LengthTooShort ->
            "Username is too short"

        _ ->
            ""
