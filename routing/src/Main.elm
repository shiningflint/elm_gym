module Main exposing (main)

import Browser
import Html exposing (..)
import Url



-- MODEL


type alias Model =
    Int


init : () -> url -> key -> ( Model, Cmd Msg )
init _ url key =
    ( 0, Cmd.none )



-- UPDATE


type Msg
    = UrlChange
    | UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


onUrlChange : Url.Url -> Msg
onUrlChange url =
    UrlChange


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest urlRequest =
    UrlRequest


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Main title", body = [ div [] [ text "Hello babanas" ] ] }


main =
    Browser.application { init = init, update = update, view = view, onUrlChange = onUrlChange, onUrlRequest = onUrlRequest, subscriptions = subscriptions }
