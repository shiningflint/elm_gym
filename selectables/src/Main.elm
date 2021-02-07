module Main exposing (main)

import Browser
import DrawItem
import DrawSvg
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Set exposing (Set)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { selectables = ( DrawItem.drawItems, DrawItem.selectedValueIds )
      , drawIds = DrawItem.drawIds
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { selectables : ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    , drawIds : List DrawItem.DrawId
    }



-- UPDATE


type Msg
    = ToggleSelect DrawItem.ValueId


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



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ DrawSvg.draw generateSvgString model.drawIds model.selectables
        ]


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



-- SVG INPUT


generateSvgString : String
generateSvgString =
    """<svg width="181px" height="181px" viewbox="-0.5 -0.5 181 181"><g><rect id="seat01" x="0" y="0" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect id="seat02" x="0" y="100" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect id="seat03" x="100" y="0" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect id="seat04" x="100" y="100" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /></g></svg>"""
