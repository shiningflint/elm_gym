module Main exposing (main)

import Browser
import Html exposing (..)
import Time


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { reservations : List Reservation
    }


init : Model
init =
    { reservations = trainTickets
    }



-- UPDATE


update : msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Html msg
view model =
    div []
        [ reservationsTable model.reservations
        ]


reservationsTable : List Reservation -> Html msg
reservationsTable res =
    let
        reservationRows =
            List.map
                (\r ->
                    tr []
                        [ td [] [ text r.name ]
                        , td [] [ text r.stationFrom ]
                        , td [] [ text r.stationTo ]
                        , td [] [ text <| localHumanFormat r.departAt ]
                        , td [] [ text <| localHumanFormat r.arriveAt ]
                        ]
                )
                res
    in
    table []
        [ thead []
            [ tr []
                [ td [] [ text "name" ]
                , td [] [ text "Depart from" ]
                , td [] [ text "Arrive at" ]
                , td [] [ text "Departure time" ]
                , td [] [ text "Arrival time" ]
                ]
            ]
        , tbody [] reservationRows
        ]



-- Time Utilities


localHumanFormat : Time.Posix -> String
localHumanFormat posix =
    let
        year =
            Time.toYear Time.utc posix |> String.fromInt

        month =
            Time.toMonth Time.utc posix |> monthToNumber |> String.fromInt |> String.padLeft 2 '0'

        day =
            Time.toDay Time.utc posix |> String.fromInt

        hour =
            Time.toHour Time.utc posix |> String.fromInt |> String.padLeft 2 '0'

        minute =
            Time.toMinute Time.utc posix |> String.fromInt |> String.padLeft 2 '0'

        dateSeparator =
            "-"

        timeSeparator =
            ":"
    in
    year ++ dateSeparator ++ month ++ dateSeparator ++ day ++ " " ++ hour ++ timeSeparator ++ minute


monthToNumber : Time.Month -> Int
monthToNumber month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12



-- Reservation


type alias Reservation =
    { name : String
    , stationFrom : String
    , stationTo : String
    , departAt : Time.Posix
    , arriveAt : Time.Posix
    }


trainTickets =
    [ Reservation "Bambang Santoso" "Tokyo" "Niigata" (Time.millisToPosix 1612930440000) (Time.millisToPosix 1612938060000)
    , Reservation "Olivia Olio" "Beijing" "Chengdu" (Time.millisToPosix 1615331040000) (Time.millisToPosix 1615359840000)
    ]
