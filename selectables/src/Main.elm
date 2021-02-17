module Main exposing (main)

import Browser
import DrawItem
import DrawSvg
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Set exposing (Set)


main : Program D.Value Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }


init : D.Value -> ( Model, Cmd Msg )
init config =
    case D.decodeValue configDecoder config of
        Ok c ->
            ( { selectables =
                    Just
                        { selectableIds = c.selectableIds
                        , selected = Set.fromList c.selected
                        , disabled = Set.fromList c.disabled
                        , maxSelection = c.maxSelection
                        }
              , svgString = Idle
              }
            , getSvgString c.svgSrc
            )

        Err e ->
            ( { selectables = Nothing
              , svgString = Idle
              }
            , Cmd.none
            )



-- CONFIG


type alias Config =
    { svgSrc : String
    , selectableIds : List DrawItem.DrawId
    , selected : List DrawItem.DrawId
    , disabled : List DrawItem.DrawId
    , maxSelection : Int
    }


configDecoder : Decoder Config
configDecoder =
    D.succeed Config
        |> required "svgSrc" D.string
        |> optional "selectableIds" (D.list D.string) []
        |> optional "selected" (D.list D.string) []
        |> optional "disabled" (D.list D.string) []
        |> optional "maxSelection" D.int 1



-- MODEL


type alias Model =
    { selectables : Maybe DrawItem.Selectables
    , svgString : SvgString
    }


type SvgString
    = Idle
    | SvgString (Result Http.Error String)



-- UPDATE


type Msg
    = ToggleSelect DrawItem.ValueId
    | GotSvgString (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.selectables ) of
        ( ToggleSelect valueId, Just selectables ) ->
            let
                newSelected =
                    DrawItem.toggleSelected valueId selectables.selected selectables.maxSelection

                newSelectables =
                    Just
                        { selectableIds = selectables.selectableIds
                        , selected = newSelected
                        , disabled = selectables.disabled
                        , maxSelection = selectables.maxSelection
                        }
            in
            ( { model | selectables = newSelectables }, Cmd.none )

        ( GotSvgString result, Just selectables ) ->
            ( { model | svgString = SvgString result }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


getSvgString : String -> Cmd Msg
getSvgString url =
    Http.get
        { url = url
        , expect = Http.expectString GotSvgString
        }



-- VIEW


view : Model -> Html Msg
view model =
    let
        svgContent =
            case model.selectables of
                Nothing ->
                    [ text "Fatal error, please check required fields" ]

                Just selectables ->
                    case model.svgString of
                        Idle ->
                            []

                        SvgString (Ok svgString) ->
                            [ DrawSvg.draw svgString selectables ToggleSelect ]

                        SvgString (Err httpError) ->
                            [ svgHttpErrorView httpError ]
    in
    div [] svgContent


svgHttpErrorView : Http.Error -> Html Msg
svgHttpErrorView httpError =
    case httpError of
        Http.BadUrl url ->
            text ("Http error: " ++ url)

        Http.Timeout ->
            text "Http error timeout"

        Http.NetworkError ->
            text "Http network error"

        Http.BadStatus 404 ->
            text "Error when fetching SVG URL. Not found."

        Http.BadStatus status ->
            text <| "Http error status: " ++ String.fromInt status

        Http.BadBody body ->
            text ("Http error: " ++ body)
