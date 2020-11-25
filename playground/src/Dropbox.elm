module Dropbox exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (style, type_, value)
import Html.Events exposing (onClick, onInput)



-- MODEL


type alias DropboxUser =
    { accessToken : String }


type alias Model =
    { doc : String
    , dropboxUser : Maybe DropboxUser
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { doc = "Here are some bananas"
      , dropboxUser = Nothing

      -- , dropboxUser = Just { accessToken = "banana_token" }
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SaveToDropbox
    | SetDoc String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveToDropbox ->
            let
                _ =
                    case model.dropboxUser of
                        Nothing ->
                            Debug.log "Need to authenticate. Bring the popup" ""

                        Just dropboxUser ->
                            Debug.log "Authorized, saving" dropboxUser.accessToken
            in
            ( model, Cmd.none )

        SetDoc newDoc ->
            ( { model | doc = newDoc }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ textarea
            [ style "width" "400px"
            , style "height" "100px"
            , value model.doc
            , onInput SetDoc
            ]
            []
        , br [] []
        , p [] [ text model.doc ]
        , button
            [ type_ "button"
            , onClick SaveToDropbox
            ]
            [ text "Save to dropbox" ]
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
