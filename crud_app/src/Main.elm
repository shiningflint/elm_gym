module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import User exposing (User)



-- MODEL


type alias Model =
    { title : Title
    , users : Status (List User)
    , user : Status User
    }


type alias Title =
    String


type Status a
    = Loading
    | Loaded a


init : () -> ( Model, Cmd Msg )
init flags =
    ( { title = "User List"
      , user = Loading
      , users = Loading
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GetUser User
    | GetUsers
    | GotUser (Result Http.Error User)
    | GotUsers (Result Http.Error (List User))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetUser u ->
            ( { model | user = Loading }, getUser u )

        GetUsers ->
            ( { model | users = Loading }, getUsers )

        GotUser (Ok user) ->
            ( { model | user = Loaded user }, Cmd.none )

        GotUser (Err error) ->
            ( model, Cmd.none )

        GotUsers (Ok users) ->
            ( { model | users = Loaded users }, Cmd.none )

        GotUsers (Err error) ->
            ( model, Cmd.none )


getUsers : Cmd Msg
getUsers =
    Http.get
        { url = "http://localhost:3000/users"
        , expect = Http.expectJson GotUsers User.listDecoder
        }


getUser : User -> Cmd Msg
getUser user =
    Http.get
        { url = "http://localhost:3000/users/" ++ User.idString user
        , expect = Http.expectJson GotUser User.decoder
        }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ headerView model.title
        , bodyView model.users
        , userDetail model.user
        ]


headerView : Title -> Html Msg
headerView title =
    header []
        [ h2 [] [ text title ]
        ]


bodyView : Status (List User) -> Html Msg
bodyView users =
    let
        usersSection =
            case users of
                Loading ->
                    p [] [ text "Loading..." ]

                Loaded us ->
                    userTable us
    in
    div []
        [ usersSection
        , button [ onClick GetUsers ] [ text "Load users" ]
        ]


userTable : List User -> Html Msg
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
                (\u ->
                    tr []
                        [ td [] [ text <| User.idString u ]
                        , td [] [ text <| User.email u ]
                        , td []
                            [ button [ onClick <| GetUser u ] [ text "Get user" ]
                            ]
                        ]
                )
                users
        ]


userDetail : Status User -> Html Msg
userDetail user =
    let
        userSection =
            case user of
                Loading ->
                    p [] [ text "Loading..." ]

                Loaded us ->
                    p []
                        [ span [] [ text <| User.idString us ]
                        , br [] []
                        , span [] [ text <| User.email us ]
                        ]
    in
    div [] [ userSection ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
