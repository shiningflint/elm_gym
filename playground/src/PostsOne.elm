module PostsOne exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)



-- MODEL


type alias Model =
    { post : Post
    }


type alias Post =
    { id : Int
    , title : String
    }


dummyPost =
    Post 13 "Bananas eat Potatoes"



-- VIEW


view : Model -> Html msg
view model =
    div []
        [ div [] [ text "Here are some posts" ]
        , div [] [ text "Le title" ]
        , div [] [ text model.post.title ]
        , button [] [ text "Load Posts" ]
        , p [] [ text "or" ]
        , a [ href "/" ] [ text "Home page" ]
        ]


init : ( Model, Cmd msg )
init =
    ( { post = Post 0 "Fake title here bananas" }, Cmd.none )
