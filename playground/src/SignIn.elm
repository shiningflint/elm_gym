module SignIn exposing (main)
import Browser
import Html exposing (Html, div, h1, button, form, input, text)
import Html.Attributes exposing (type_, placeholder, value)
import Html.Events exposing (onInput, onSubmit)

-- MODEL

type alias Model =
  { email : String
  , submitMessage : String
  }

init : Model
init =
  { email = ""
  , submitMessage = ""
  }

-- UPDATE

type Msg
  = Email String
  | FormSubmit

update : Msg -> Model -> Model
update msg model =
  case msg of
    Email email ->
      { model | email = email }
    FormSubmit ->
      if model.email /= "banana" then
        { model | submitMessage = "Error, email address is not bananas" }
      else
        { model | submitMessage = "" }

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text "Please sign-in to continue" ]
    , form [ onSubmit FormSubmit ]
      [ input [ type_ "text", placeholder "email address", value model.email, onInput Email ] []
      , button [ type_ "submit" ] [ text "Sign-in" ]
      ]
    , div [] [ text model.email ]
    , div [] [ text model.submitMessage ]
    ]

-- MAIN

main = Browser.sandbox { init = init, update = update, view = view }
