module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Post
import RemoteData exposing (..)


type alias Model =
    { posts : WebData (List Post.Post)
    , errorMessage : Maybe String
    }



-- UPDATE


type Msg
    = SendHttpRequest
    | RemoteDataReceived (WebData (List Post.Post))


httpCommand : Cmd Msg
httpCommand =
    Http.get
        { url = "http://localhost:3003/posts"
        , expect = Http.expectJson (RemoteData.fromResult >> RemoteDataReceived) Post.postsDecoder
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( { model | posts = Loading }, httpCommand )

        RemoteDataReceived response ->
            ( { model | posts = response }
            , Cmd.none
            )


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message



-- VIEW


viewPost : Post.Post -> Html Msg
viewPost post =
    tr []
        [ td [] [ text (String.fromInt post.id) ]
        , td [] [ text post.title ]
        , td [] [ text post.author ]
        ]


viewTableHeader : Html Msg
viewTableHeader =
    tr []
        [ th [] [ text "ID" ]
        , th [] [ text "Title" ]
        , th [] [ text "Author" ]
        ]


viewPosts : List Post.Post -> Html Msg
viewPosts posts =
    div []
        [ h3 [] [ text "Posts" ]
        , table []
            ([ viewTableHeader ] ++ List.map viewPost posts)
        ]


viewError : String -> Html Msg
viewError message =
    let
        errorHeading =
            "Couldn't fetch data at this time"
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ message)
        ]


viewPostsOrError : Model -> Html Msg
viewPostsOrError model =
    case model.posts of
        NotAsked ->
            text "Click to load posts"

        Loading ->
            text "Loading"

        Failure httpError ->
            text ("Error: " ++ buildErrorMessage httpError)

        Success posts ->
            viewPosts posts


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , viewPostsOrError model
        ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( { posts = NotAsked
      , errorMessage = Nothing
      }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
