module HttpRequest exposing (main)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Browser

main : Program () Model Msg
main = Browser.element
  { init = \flags -> ( [], Cmd.none )
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

-- MODEL

type alias Model =
  List String

init : Model
init = []

-- UPDATE

type Msg
  = SendHttpRequest
  | DataReceived (Result Http.Error String)

url = "http://localhost:3003/old-school.txt"
githubUrl = "https://api.github.com/repos/git/git"

getNicknames : Cmd Msg
getNicknames =
  Http.get
    { url = url
    , expect = Http.expectString DataReceived
    }

getGithubRepo =
  Http.get
    { url = githubUrl
    , expect = Http.expectJson GithubReceived
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SendHttpRequest ->
      ( model, getNicknames )
    DataReceived (Ok nicknameStr) ->
      let nicknames = String.split "," nicknameStr
      in ( nicknames, Cmd.none )
    DataReceived (Err _) ->
      ( model, Cmd.none )
    GetGithub ->
      ( model, getGithubRepo )

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick SendHttpRequest ]
      [ text "Get data from server" ]
    , h3 [] [ text "Old School Main Characters" ]
    , ul [] (List.map viewNickname model)
    ]

viewNickname : String -> Html Msg
viewNickname nickname =
  li [] [ text nickname ]
