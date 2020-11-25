-- This is for learning the general wisdom of Elm.
-- "Extract the type and make it opaque"
-- refer to
-- Opaque type for validation
-- https://dev.to/izumisy/designing-opaque-type-for-form-fields-in-elm-4299
-- Further reading:
-- https://medium.com/@ckoster22/advanced-types-in-elm-opaque-types-ec5ec3b84ed2


module UsernameValidationOpaque exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput)
import Username



-- MODEL


type alias Model =
    { username : Username.Username }


init : Model
init =
    { username = Username.empty }



-- UPDATE


type Msg
    = UsernameInputted Username.Username
    | UsernameBlurred


update : Msg -> Model -> Model
update msg model =
    case msg of
        UsernameInputted username ->
            { model | username = username }

        UsernameBlurred ->
            let
                _ =
                    Debug.log "on blur" model.username
            in
            { model | username = Username.blur model.username }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text "Username" ]
        , Username.input model.username UsernameInputted UsernameBlurred
        , p [] [ text <| Username.errorMessage model.username ]
        ]


main =
    Browser.sandbox { init = init, update = update, view = view }
