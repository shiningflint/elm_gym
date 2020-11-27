module InputField exposing (InputField, blur, errorResult, init, input, toString)

import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onBlur, onInput)


type InputField err
    = Partial (Common err)
    | Valid (Common err)
    | Invalid (Common err) err


type alias Common err =
    { value : String
    , validator : String -> Result err String
    }


init : String -> (String -> Result err String) -> InputField err
init initValue validator =
    Partial { value = initValue, validator = validator }


input : InputField err -> (InputField err -> msg) -> msg -> Html msg
input inputField onInputMsg onBlurMsg =
    let
        onInputHandler =
            \value ->
                onInputMsg <|
                    case inputField of
                        Partial common ->
                            Partial { value = value, validator = common.validator }

                        Valid common ->
                            Valid { value = value, validator = common.validator }

                        Invalid common err ->
                            Invalid { value = value, validator = common.validator } err
    in
    Html.input
        [ type_ "text"
        , value <| toString inputField
        , onInput onInputHandler
        , onBlur onBlurMsg
        ]
        []


blur : InputField err -> InputField err
blur inputField =
    case inputField of
        Partial { value, validator } ->
            mapResult inputField <| validator value

        Valid { value, validator } ->
            mapResult inputField <| validator value

        Invalid { value, validator } _ ->
            mapResult inputField <| validator value


errorResult : InputField err -> Result err String
errorResult inputField =
    case inputField of
        Invalid common err ->
            Err err

        _ ->
            Ok ""



-- Internals


inputFieldValidator : InputField err -> (String -> Result err String)
inputFieldValidator inputField =
    case inputField of
        Partial { validator } ->
            validator

        Valid { validator } ->
            validator

        Invalid { validator } _ ->
            validator


mapResult : InputField err -> Result err String -> InputField err
mapResult inputField result =
    case result of
        Ok value ->
            Valid
                { value = value, validator = inputFieldValidator inputField }

        Err err ->
            Invalid
                { value = "", validator = inputFieldValidator inputField }
                err


toString : InputField err -> String
toString inputField =
    case inputField of
        Partial common ->
            common.value

        Valid common ->
            common.value

        Invalid common _ ->
            common.value
