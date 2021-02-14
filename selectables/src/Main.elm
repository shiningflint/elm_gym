module Main exposing (main)

import Browser
import DrawItem
import DrawSvg
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Set exposing (Set)


main : Program Config Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }


init : Config -> ( Model, Cmd Msg )
init config =
    ( { selectables = ( config.selectableIds, Set.fromList config.selected )
      , svgString = Idle
      }
    , getSvgString config.svgSrc
    )



-- MODEL


type alias Model =
    { selectables : ( List DrawItem.DrawId, Set DrawItem.DrawId )
    , svgString : SvgString
    }


type alias Config =
    { svgSrc : String
    , selectableIds : List DrawItem.DrawId
    , selected : List DrawItem.DrawId
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
    case msg of
        ToggleSelect valueId ->
            let
                sValueIds =
                    model.selectables |> Tuple.first

                sSelectedIds =
                    model.selectables |> Tuple.second

                newSselectedIds =
                    if Set.member valueId sSelectedIds then
                        Set.remove valueId sSelectedIds

                    else
                        Set.insert valueId sSelectedIds
            in
            ( { model | selectables = ( sValueIds, newSselectedIds ) }, Cmd.none )

        GotSvgString result ->
            ( { model | svgString = SvgString result }, Cmd.none )


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
            case model.svgString of
                Idle ->
                    []

                SvgString (Ok svgString) ->
                    [ DrawSvg.draw svgString model.selectables ToggleSelect ]

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
