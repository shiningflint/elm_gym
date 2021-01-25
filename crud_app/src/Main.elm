module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import User exposing (User)



-- MODEL


type alias Model =
    { title : Title
    , users : Status (List User)
    , user : Status User
    , userForm : User.UserForm
    }


type alias Title =
    String


type Status a
    = Loading
    | Loaded a
    | Waiting


init : () -> ( Model, Cmd Msg )
init flags =
    ( { title = "User List"
      , user = Waiting
      , users = Waiting
      , userForm = User.Idle
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GetUser User
    | GetUsers
    | GotUser (Result Http.Error User)
    | GotUsers (Result Http.Error (List User))
    | EnteredId String
    | EnteredEmail String
    | ClickedSave
    | ClickedEditSave
    | ClickedDelete User
    | ClickedNewUser
    | ClickedEdit User
    | PostedUser (Result Http.Error String)
    | PuttedUser (Result Http.Error String)
    | DeletedUser (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedSave ->
            ( model, postUser <| User.formToUser <| User.getForm model.userForm )

        ClickedEditSave ->
            ( model, putUser <| User.formToUser <| User.getForm model.userForm )

        ClickedDelete u ->
            ( model, deleteUser u )

        ClickedNewUser ->
            ( { model | userForm = User.New User.emptyForm }, Cmd.none )

        ClickedEdit u ->
            ( { model | userForm = User.userToForm u |> User.Edit }
            , Cmd.none
            )

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

        EnteredId id ->
            let
                idInt =
                    String.toInt id
                        |> Maybe.withDefault 0

                usrForm =
                    case model.userForm of
                        User.New f ->
                            User.updateForm f (\form -> { form | id = idInt })
                                |> User.New

                        User.Edit f ->
                            User.updateForm f (\form -> { form | id = idInt })
                                |> User.Edit

                        User.Idle ->
                            User.Idle
            in
            ( { model | userForm = usrForm }
            , Cmd.none
            )

        EnteredEmail email ->
            let
                usrForm =
                    case model.userForm of
                        User.New f ->
                            User.updateForm f (\form -> { form | email = email })
                                |> User.New

                        User.Edit f ->
                            User.updateForm f (\form -> { form | email = email })
                                |> User.Edit

                        User.Idle ->
                            User.Idle
            in
            ( { model | userForm = usrForm }
            , Cmd.none
            )

        PostedUser reply ->
            let
                _ =
                    Debug.log "posted user reply" reply
            in
            ( { model | userForm = User.Idle }, getUsers )

        PuttedUser reply ->
            let
                _ =
                    Debug.log "deleted user reply" reply
            in
            ( { model | userForm = User.Idle }, getUsers )

        DeletedUser reply ->
            let
                _ =
                    Debug.log "deleted user reply" reply
            in
            ( { model | user = Waiting }, getUsers )


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


postUser : User -> Cmd Msg
postUser user =
    Http.post
        { url = "http://localhost:3000/users/"
        , body = Http.stringBody "application/json" <| User.json user
        , expect = Http.expectString PostedUser
        }


putUser : User -> Cmd Msg
putUser user =
    Http.request
        { method = "PUT"
        , url = "http://localhost:3000/users/" ++ User.idString user
        , expect = Http.expectString PuttedUser
        , timeout = Nothing
        , tracker = Nothing
        , body = Http.stringBody "application/json" <| User.json user
        , headers = []
        }


deleteUser : User -> Cmd Msg
deleteUser user =
    Http.request
        { method = "DELETE"
        , url = "http://localhost:3000/users/" ++ User.idString user
        , expect = Http.expectString DeletedUser
        , timeout = Nothing
        , tracker = Nothing
        , body = Http.emptyBody
        , headers = []
        }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ headerView model.title
        , bodyView model.users model.userForm
        , userDetail model.user
        ]


headerView : Title -> Html Msg
headerView title =
    header []
        [ h2 [] [ text title ]
        ]


bodyView : Status (List User) -> User.UserForm -> Html Msg
bodyView users userForm =
    let
        usersSection =
            case users of
                Waiting ->
                    p [] []

                Loading ->
                    p [] [ text "Loading..." ]

                Loaded us ->
                    userTable us

        userFormView =
            case userForm of
                User.Idle ->
                    button [ onClick ClickedNewUser ] [ text "Create new user" ]

                _ ->
                    userDetailForm userForm
    in
    div []
        [ userFormView
        , usersSection
        , button [ onClick GetUsers ] [ text "Load users" ]
        ]


userDetailForm : User.UserForm -> Html Msg
userDetailForm userForm =
    let
        uForm =
            User.getForm userForm

        userId =
            uForm.id |> String.fromInt

        userEmail =
            uForm.email

        submitButton =
            case userForm of
                User.New f ->
                    button [ onClick ClickedSave, type_ "button" ] [ text "Register user" ]

                User.Edit f ->
                    button [ onClick ClickedEditSave, type_ "button" ] [ text "Save existing user" ]

                User.Idle ->
                    span [] [ text "Should not happen" ]
    in
    div []
        [ form []
            [ input [ onInput EnteredId, value userId ] []
            , input [ onInput EnteredEmail, value userEmail ] []
            , submitButton
            ]
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
                Waiting ->
                    p [] []

                Loading ->
                    p [] [ text "Loading..." ]

                Loaded us ->
                    div []
                        [ p []
                            [ span [] [ text <| User.idString us ]
                            , br [] []
                            , span [] [ text <| User.email us ]
                            ]
                        , button [ onClick (ClickedEdit us) ] [ text "Edit user" ]
                        , button [ onClick (ClickedDelete us) ] [ text "Delete user" ]
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
