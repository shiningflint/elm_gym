module Navigation exposing (..)

import Browser
import Browser.Navigation as Nav
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { counter : Int
    , url : Url.Url
    , key : Nav.Key
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { counter = 0
      , url = url
      , key = key
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    let
                        command =
                            Nav.pushUrl model.key (Url.toString url)
                    in
                    ( model, command )

                Browser.External url ->
                    ( model, Nav.load url )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "URL Interceptor!"
    , body =
        [ div []
            [ text
                ("Current URL: " ++ Url.toString model.url)
            ]
        , div []
            [ text "External links: "
            , br [] []
            , a [ href "https://acbw.me" ] [ text "Link to acbw.me" ]
            ]
        , br [] []
        , div []
            [ text "Internal links: "
            , br [] []
            , a [ href "/posts" ] [ text "going to posts" ]
            ]
        ]
    }
