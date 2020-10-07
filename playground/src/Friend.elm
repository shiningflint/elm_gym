module Friend exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Friend
    = Less String
    | More String Info


type alias Info =
    { age : Int
    }



-- INIT


init : Friend
init =
    Less "Bananas"



-- UPDATE


type Msg
    = SetName String
    | SetAge String


update : Msg -> Friend -> Friend
update msg friend =
    case msg of
        SetName newName ->
            case friend of
                Less name ->
                    Less newName

                More name info ->
                    More newName info

        SetAge newAge ->
            case friend of
                More name info ->
                    More name { info | age = Maybe.withDefault 0 (String.toInt newAge) }

                Less name ->
                    More name { age = Maybe.withDefault 0 (String.toInt newAge) }



-- VIEW


getName : Friend -> String
getName friend =
    case friend of
        Less name ->
            name

        More name info ->
            name



-- value function always expects string even if the input type is number
-- So I will have to interface between Int & String when getting/setting age


getAge : Friend -> String
getAge friend =
    case friend of
        More name info ->
            String.fromInt info.age

        _ ->
            "0"


view : Friend -> Html Msg
view friend =
    div []
        [ Html.form []
            [ div []
                [ label [ for "name" ] [ text "Name" ]
                , input
                    [ type_ "text"
                    , id "name"
                    , value (getName friend)
                    , onInput SetName
                    ]
                    []
                , p [] [ text (getName friend) ]
                ]
            , div []
                [ label [ for "age" ] [ text "Age" ]
                , input
                    [ type_ "number"
                    , id "age"
                    , value (getAge friend)
                    , onInput SetAge
                    ]
                    []
                , p [] [ text (getAge friend) ]
                ]
            ]
        ]


main =
    Browser.sandbox { init = init, update = update, view = view }
