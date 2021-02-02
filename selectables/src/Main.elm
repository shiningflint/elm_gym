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
    ( { selectables = ( valueIds, selectedValueIds ) }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { selectables : ( List ValueId, Set ValueId ) }



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

                _ =
                    Debug.log "toggle value id" valueId
            in
            ( { model | selectables = ( sValueIds, newSselectedIds ) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ drawing model.selectables
        ]


drawing : ( List ValueId, Set ValueId ) -> Html Msg
drawing selectables =
    let
        sValueIds =
            Tuple.first selectables

        sSelectedIds =
            Tuple.second selectables

        valueItem =
            \valueId ->
                let
                    selectedClass =
                        if Set.member valueId sSelectedIds then
                            class "selected"

                        else
                            class ""
                in
                div
                    [ class "item"
                    , selectedClass
                    , onClick <| ToggleSelect valueId
                    ]
                    [ span [] [ text valueId ] ]
    in
    div [ class "item-wrap" ] <| List.map valueItem sValueIds



-- VALUEID


type alias ValueId =
    String


valueIds : List ValueId
valueIds =
    [ "1A", "1B", "2A", "2B" ]


selectedValueIds : Set ValueId
selectedValueIds =
    Set.fromList [ "2A", "1B" ]
