module Potato exposing (Model, Msg, init, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (type_)
import Html.Events exposing (onInput)



-- MODEL


type alias Model =
    { name : String }


init : Model
init =
    { name = "" }



-- UPDATE


type Msg
    = EnteredName String


update : Msg -> Model -> Model
update msg model =
    case msg of
        EnteredName value ->
            { model | name = value }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Name your potato!" ]
        , div []
            [ p [] [ text "What is the name of your potato?" ]
            , input [ type_ "text", onInput EnteredName ] []
            , p [] [ text <| "your potato name is: " ++ model.name ]
            ]
        ]
