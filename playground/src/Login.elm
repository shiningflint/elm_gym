module Login exposing (..)
import Html exposing (div, text)
import Browser

main = Browser.sandbox { init = 0, update = loginUpdate, view = loginView }

loginUpdate msg model =
  case msg of
    1 ->
      1
    _ ->
      2

loginView model =
  div [] [ text "babanas" ]
