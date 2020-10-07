module SignUp exposing (main)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

-- MODEL

type alias User =
  { name : String
  , email : String
  , password : String
  , loggedIn : Bool
  }

init : User
init =
  { name = ""
  , email = ""
  , password = ""
  , loggedIn = False
  }

-- UPDATE

type Msg
  = UpdateName String
  | UpdateEmail String
  | UpdatePassword String
  | FormSubmit
  | Signout

update : Msg -> User -> User
update msg user =
  case msg of
    UpdateName name ->
      { user | name = name }
    UpdateEmail email ->
      { user | email = email }
    UpdatePassword password ->
      { user | password = password }
    FormSubmit ->
      { user | loggedIn = True }
    Signout ->
      { user | loggedIn = False }

-- VIEW

formWrapper : List (Attribute msg)
formWrapper =
  [ style "width" "400px"
  , style "margin" "auto"
  ]

formStyle : List (Attribute msg)
formStyle =
  [ style "border-radius" "5px"
  , style "background-color" "#f2f2f2"
  , style "padding" "16px"
  ]

inputStyle : List (Attribute msg)
inputStyle =
  [ style "display" "block"
  , style "width" "260px"
  , style "padding" "12px"
  , style "margin" "8px 0"
  , style "border" "none"
  , style "border-radius" "5px"
  ]

buttonStyle : List (Attribute msg)
buttonStyle =
  [ style "width" "260px"
  , style "background-color" "#397cd5"
  , style "color" "white"
  , style "font-size" "16px"
  , style "border-radius" "5px"
  , style "border" "none"
  , style "padding" "12px"
  , style "margin-top" "16px"
  ]

formComponent : User -> Html Msg
formComponent user =
  Html.form ( [onSubmit FormSubmit] ++ formStyle )
    [ div []
      [ text "Name"
      , input ([ id "name", type_ "text", onInput UpdateName ] ++ inputStyle) []
      , p [] [ text user.name ]
      ]
    , div []
      [ text "Email"
      , input ([ id "email", type_ "email", onInput UpdateEmail ] ++ inputStyle) []
      , p [] [ text user.email ]
      ]
    , div []
      [ text "password"
      , input ([ id "password", type_ "password", onInput UpdatePassword ] ++ inputStyle) []
      ]
    , div []
      [ button ([ type_ "submit" ] ++ buttonStyle)
        [ text "Create my account" ]
      ]
    ]

userDetailComponent : User -> Html Msg
userDetailComponent user =
  div []
    [ p [] [ text ("Welcome " ++ user.name ++ "!") ]
    , button [ type_ "button", onClick Signout ] [ text "Signout" ]
    ]

view : User -> Html Msg
view user =
  div formWrapper
    [ h1 [] [ text "Sign up" ]
    , if user.loggedIn == True then userDetailComponent user else formComponent user
    ]

-- MAIN

main =
  Browser.sandbox { init = init, update = update, view = view }
