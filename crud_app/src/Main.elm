module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http



-- MODEL


type alias Model =
    { title : Title
    , users : Status (List String)
    }


type alias Title =
    String


type Status a
    = Loading
    | Loaded a


init : () -> ( Model, Cmd Msg )
init flags =
    ( { title = "User List"

      -- , users = Loading
      , users = Loaded [ "bananas", "Potatoes", "Bacon" ]
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GetUsers
    | GotUsers (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetUsers ->
            ( model, getUsers )

        GotUsers (Ok users) ->
            let
                _ =
                    Debug.log "users" users
            in
            ( model, Cmd.none )

        GotUsers (Err error) ->
            ( model, Cmd.none )


getUsers : Cmd Msg
getUsers =
    Http.get
        { url = "http://localhost:3000/users"
        , expect = Http.expectString GotUsers
        }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ headerView model.title
        , bodyView model.users
        , button [ onClick GetUsers ] [ text "Load users" ]
        ]


headerView : Title -> Html Msg
headerView title =
    header []
        [ h2 [] [ text title ]
        ]


bodyView : Status (List String) -> Html Msg
bodyView users =
    case users of
        Loading ->
            p [] [ text "Loading..." ]

        Loaded us ->
            userTable us


userTable : List String -> Html Msg
userTable users =
    table []
        [ thead []
            [ tr []
                [ td [] [ text "ID" ]
                , td [] [ text "email" ]
                ]
            ]
        , tbody [] <|
            List.map
                (\u -> tr [] [ td [] [ text "le id" ], td [] [ text u ] ])
                users
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
