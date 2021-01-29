module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onInput)
import Task
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { reservations : List Reservation
    , filterKeyword : String
    , timezone : Time.Zone
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { reservations = trainTickets
      , filterKeyword = ""
      , timezone = Time.utc
      }
    , getCurrentTimezone
    )



-- UPDATE


type Msg
    = CurrentTimezone Time.Zone
    | EnteredFilterKeyword String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CurrentTimezone zone ->
            let
                _ =
                    Debug.log "time zone" zone
            in
            ( { model | timezone = zone }, Cmd.none )

        EnteredFilterKeyword keyword ->
            ( { model | filterKeyword = keyword }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ reservationsFilter model.filterKeyword
        , reservationsTable model.reservations model.timezone
        ]


reservationsFilter filterKeyword =
    div [ class "mb-3" ]
        [ span [] [ text "Filter by name" ]
        , br [] []
        , input
            [ type_ "text"
            , onInput EnteredFilterKeyword
            , value filterKeyword
            ]
            []
        ]


reservationsTable : List Reservation -> Time.Zone -> Html msg
reservationsTable res timezone =
    let
        reservationRows =
            List.map
                (\r ->
                    tr []
                        [ td [] [ text r.name ]
                        , td [] [ text r.stationFrom ]
                        , td [] [ text r.stationTo ]
                        , td [] [ text <| localHumanFormat timezone r.departAt ]
                        , td [] [ text <| localHumanFormat timezone r.arriveAt ]
                        ]
                )
                res
    in
    table []
        [ thead []
            [ tr []
                [ td [] [ text "Name" ]
                , td [] [ text "Depart from" ]
                , td [] [ text "Arrive at" ]
                , td [] [ text "Departure time" ]
                , td [] [ text "Arrival time" ]
                ]
            ]
        , tbody [] reservationRows
        ]



-- Time Utilities


getCurrentTimezone : Cmd Msg
getCurrentTimezone =
    Task.perform CurrentTimezone Time.here


localHumanFormat : Time.Zone -> Time.Posix -> String
localHumanFormat zone posix =
    let
        year =
            Time.toYear zone posix |> String.fromInt

        month =
            Time.toMonth zone posix |> monthToNumber |> String.fromInt |> String.padLeft 2 '0'

        day =
            Time.toDay zone posix |> String.fromInt

        hour =
            Time.toHour zone posix |> String.fromInt |> String.padLeft 2 '0'

        minute =
            Time.toMinute zone posix |> String.fromInt |> String.padLeft 2 '0'

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
    , Reservation "Susi Susanti" "Jakarta" "Surabaya" (Time.millisToPosix 1613802540000) (Time.millisToPosix 1613804400000)
    , Reservation "佐藤神代" "Sendai" "Akita" (Time.millisToPosix 1618038000000) (Time.millisToPosix 1618041300000)
    , Reservation "Mark Pain" "Fukuoka" "Hiroshima" (Time.millisToPosix 1641005700000) (Time.millisToPosix 1641016500000)
    ]
