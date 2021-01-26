module Banana exposing (Model, Msg, init, update, view)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)



-- MODEL


type alias Model =
    { quantity : Int }


init : Model
init =
    { quantity = 0 }



-- UPDATE


type Msg
    = ClickedAdd
    | ClickedSubtract


update : Msg -> Model -> Model
update msg model =
    case msg of
        ClickedAdd ->
            { model | quantity = model.quantity + 1 }

        ClickedSubtract ->
            { model | quantity = model.quantity - 1 }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Count your bananas!" ]
        , div []
            [ button [ onClick ClickedAdd ] [ text "Add bananas" ]
            , button [ onClick ClickedSubtract ] [ text "Subtract bananas" ]
            , p [] [ text <| "How much bananas you have: " ++ String.fromInt model.quantity ]
            ]
        ]
