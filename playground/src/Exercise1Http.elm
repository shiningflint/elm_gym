module Exercise1Http exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http



-- MODEL


type alias Model =
    { content : String
    , fetchMessageError : String
    }


init : flags -> ( Model, Cmd Msg )
init flags =
    ( { content = ""
      , fetchMessageError = ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = FetchMessage
    | MessageFetched (Result Http.Error String)


fetchMessage : Cmd Msg
fetchMessage =
    Http.get
        { url = "http://localhost:3003/Exercise1Http.txt"
        , expect = Http.expectString MessageFetched
        }


fetchError : Http.Error -> String
fetchError error =
    case error of
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
        FetchMessage ->
            let
                l =
                    Debug.log "Fetch message: " "fetching"
            in
            ( { model | fetchMessageError = "" }, fetchMessage )

        MessageFetched (Ok goodies) ->
            ( { model | content = goodies }, Cmd.none )

        MessageFetched (Err error) ->
            ( { model | fetchMessageError = fetchError error }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text "Click to load message" ]
        , p [] [ text model.content ]
        , p [] [ text model.fetchMessageError ]
        , button [ onClick FetchMessage ] [ text "Load message" ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
