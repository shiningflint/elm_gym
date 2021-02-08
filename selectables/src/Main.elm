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
    ( { selectables = ( DrawItem.drawItems, DrawItem.selectedValueIds )
      , drawIds = DrawItem.drawIds
      , svgString = Nothing
      }
    , getSvgString config.svgSrc
    )



-- MODEL


type alias Model =
    { selectables : ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    , drawIds : List DrawItem.DrawId
    , svgString : Maybe String
    }


type alias Config =
    { svgSrc : String }



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

        GotSvgString (Ok svgString) ->
            ( { model | svgString = Just svgString }, Cmd.none )

        GotSvgString (Err error) ->
            ( { model | svgString = Nothing }, Cmd.none )


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
                Nothing ->
                    []

                Just svgString ->
                    [ DrawSvg.draw svgString model.drawIds model.selectables ToggleSelect ]
    in
    div [] svgContent


drawing : ( List DrawItem.DrawItem, Set DrawItem.ValueId ) -> List DrawItem.DrawId -> Html Msg
drawing selectables drawings =
    let
        sDrawItems =
            Tuple.first selectables

        sSelectedIds =
            Tuple.second selectables

        drawItem =
            \drawId ->
                let
                    filteredDrawRecord =
                        List.filter (\i -> i.drawId == drawId) sDrawItems

                    htmlItem =
                        case List.head filteredDrawRecord of
                            Nothing ->
                                div
                                    [ class "item"
                                    , class "disabled"
                                    ]
                                    [ span [] [ text "N/A" ] ]

                            Just d ->
                                let
                                    selectedClass =
                                        if Set.member d.valueId sSelectedIds then
                                            class "selected"

                                        else
                                            class ""
                                in
                                div
                                    [ class "item"
                                    , selectedClass
                                    , onClick <| ToggleSelect d.valueId
                                    ]
                                    [ span [] [ text d.valueId ] ]
                in
                htmlItem
    in
    div [ class "item-wrap" ] <| List.map drawItem drawings
