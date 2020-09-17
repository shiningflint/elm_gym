module JsonRequest exposing (main)

import Browser
import Debug
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, decodeString, list, string)


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( [], Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    List String


init : Model
init =
    []



-- UPDATE


type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error (List String))


url =
    "http://localhost:3003/old-school.json"


nicknameDecoder : Decoder (List String)
nicknameDecoder =
    list string


getNicknames : Cmd Msg
getNicknames =
    Http.get
        { url = url
        , expect = Http.expectJson DataReceived nicknameDecoder
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, getNicknames )

        DataReceived (Ok nicknames) ->
            ( nicknames, Cmd.none )

        DataReceived (Err httpError) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , h3 [] [ text "Old School Main Characters" ]
        , ul [] (List.map viewNickname model)
        ]


viewNickname : String -> Html Msg
viewNickname nickname =
    li [] [ text nickname ]
