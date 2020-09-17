module HttpRequest exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http


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
    | DataReceived (Result Http.Error String)


url =
    "http://localhost:3003/old-school.txt"


getNicknames : Cmd Msg
getNicknames =
    Http.get
        { url = url
        , expect = Http.expectString DataReceived
        }


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl m ->
            m

        Http.BadBody m ->
            m

        Http.Timeout ->
            "Request Timeout, RTO desu"

        Http.BadStatus i ->
            "Bad status"

        Http.NetworkError ->
            "Network error desu"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, getNicknames )

        DataReceived (Ok nicknameStr) ->
            let
                nicknames =
                    String.split "," nicknameStr
            in
            ( { model | nicknames = nicknames }, Cmd.none )

        DataReceived (Err httpError) ->
            ( { model | errorMessage = buildErrorMessage httpError }
            , Cmd.none
            )



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
