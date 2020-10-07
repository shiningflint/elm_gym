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
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { nicknames : List String
    , errorMessage : String
    }


init : flags -> ( Model, Cmd Msg )
init flags =
    ( { nicknames = []
      , errorMessage = ""
      }
    , Cmd.none
    )



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


httpErrorMessage : Http.Error -> String
httpErrorMessage httpError =
    case httpError of
        Http.BadUrl err ->
            err

        Http.BadBody err ->
            err

        Http.BadStatus err ->
            String.fromInt err

        Http.Timeout ->
            "Error timeout"

        Http.NetworkError ->
            "Network error"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, getNicknames )

        DataReceived (Ok nicknames) ->
            ( { model | nicknames = nicknames }
            , Cmd.none
            )

        DataReceived (Err httpError) ->
            ( { model | errorMessage = httpErrorMessage httpError }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , h3 [] [ text "Old School Main Characters" ]
        , ul [] (List.map viewNickname model.nicknames)
        , p [] [ text model.errorMessage ]
        ]


viewNickname : String -> Html Msg
viewNickname nickname =
    li [] [ text nickname ]
