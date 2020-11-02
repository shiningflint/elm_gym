module DialogTest exposing (main)

import Browser
import Dialog
import Html exposing (..)



-- MODEL


init =
    0



-- UPDATE


update : msg -> Int -> Int
update msg model =
    model



-- VIEW


dialogConfig : Dialog.Config msg
dialogConfig =
    { closeMessage = Nothing
    , containerClass = Nothing
    , header = Nothing
    , body = Nothing
    , footer = [ div [] [ text "dialog footer" ] ]
    }


view : Int -> Html msg
view model =
    div []
        [ Dialog.view <| Just dialogConfig
        ]


main =
    Browser.sandbox { init = init, update = update, view = view }
