module Main exposing (main)

import Browser
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
    ( { selectables = ( drawItems, selectedValueIds )
      , drawIds = drawIds
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { selectables : ( List DrawItem, Set ValueId )
    , drawIds : List DrawId
    }



-- UPDATE


type Msg
    = ToggleSelect ValueId


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
        [ drawing model.selectables model.drawIds
        ]


drawing : ( List DrawItem, Set ValueId ) -> List DrawId -> Html Msg
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



-- DrawItem


type alias DrawItem =
    { drawId : DrawId
    , valueId : ValueId
    }


type alias DrawId =
    String


type alias ValueId =
    String


drawItems : List DrawItem
drawItems =
    [ { drawId = "seat01", valueId = "1A" }
    , { drawId = "seat02", valueId = "1B" }
    , { drawId = "seat03", valueId = "2A" }

    -- , { drawId = "seat04", valueId = "2B" }
    , { drawId = "seat05", valueId = "3A" }
    , { drawId = "seat06", valueId = "3B" }
    ]


selectedValueIds : Set ValueId
selectedValueIds =
    Set.fromList [ "2A", "3B" ]


drawIds : List DrawId
drawIds =
    [ "seat01"
    , "seat02"
    , "seat03"
    , "seat04"
    , "seat05"
    , "seat06"
    ]
