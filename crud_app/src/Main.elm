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
    , userForm : User.Form
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
      , userForm = User.emptyForm
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
    | ClickedDelete User
    | PostedUser (Result Http.Error String)
    | DeletedUser (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedSave ->
            let
                _ =
                    Debug.log "Saving user form" model.userForm
            in
            ( model, postUser <| User.formToUser model.userForm )

        ClickedDelete u ->
            ( model, deleteUser u )

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
            in
            ( { model | userForm = User.updateForm model.userForm (\form -> { form | id = idInt }) }
            , Cmd.none
            )

        EnteredEmail email ->
            ( { model | userForm = User.updateForm model.userForm (\form -> { form | email = email }) }
            , Cmd.none
            )

        PostedUser reply ->
            let
                _ =
                    Debug.log "posted user reply" reply
            in
            ( { model | userForm = User.emptyForm }, getUsers )

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


bodyView : Status (List User) -> User.Form -> Html Msg
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
    in
    div []
        [ newUser userForm
        , usersSection
        , button [ onClick GetUsers ] [ text "Load users" ]
        ]


newUser : User.Form -> Html Msg
newUser userForm =
    let
        userId =
            userForm.id |> String.fromInt

        userEmail =
            userForm.email
    in
    div []
        [ form []
            [ input [ onInput EnteredId, value userId ] []
            , input [ onInput EnteredEmail, value userEmail ] []
            , button [ onClick ClickedSave, type_ "button" ] [ text "Register user" ]
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
