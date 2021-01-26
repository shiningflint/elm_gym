module Main exposing (main)

import Banana
import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Potato



-- MODEL


type alias Model =
    { page : Page }


type Page
    = BananaPage Banana.Model
    | PotatoPage Potato.Model


init : Model
init =
    { page = PotatoPage Potato.init }



-- UPDATE


type Msg
    = ClickedNavigation Page
    | BananaMsg Banana.Msg
    | PotatoMsg Potato.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        ClickedNavigation page ->
            { model | page = page }

        _ ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ navigationView
        , currentView model.page
        ]


navigationView : Html Msg
navigationView =
    div []
        [ button [ onClick <| ClickedNavigation <| BananaPage Banana.init ]
            [ text "Go to banana app" ]
        , button [ onClick <| ClickedNavigation <| PotatoPage Potato.init ]
            [ text "Go to potato app" ]
        ]


currentView : Page -> Html Msg
currentView page =
    case page of
        BananaPage bananaModel ->
            Html.map BananaMsg <| Banana.view bananaModel

        PotatoPage potatoModel ->
            Html.map PotatoMsg <| Potato.view potatoModel


main =
    Browser.sandbox { init = init, update = update, view = view }
