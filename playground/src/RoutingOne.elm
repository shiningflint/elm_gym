module RoutingOne exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import PostsOne
import RouteOne
import Url



-- MODEL


type alias Model =
    { counter : Int
    , route : RouteOne.Route
    , key : Nav.Key
    , page : Page
    }


type Page
    = NotFoundPage
    | HomePage
    | PostsPage PostsOne.Model


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    initCurrentPage
        ( { counter = 0
          , route = RouteOne.toRoute url
          , key = key
          , page = NotFoundPage
          }
        , Cmd.none
        )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, command ) =
    let
        ( currentPage, currentCommand ) =
            case model.route of
                RouteOne.NotFound ->
                    ( NotFoundPage, Cmd.none )

                RouteOne.Home ->
                    ( HomePage, Cmd.none )

                RouteOne.Posts ->
                    let
                        ( postModel, postCmd ) =
                            PostsOne.init
                    in
                    ( PostsPage postModel, Cmd.none )
    in
    ( { model | page = currentPage }, currentCommand )



-- UPDATE


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            initCurrentPage ( { model | route = RouteOne.toRoute url }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    let
                        command =
                            Nav.pushUrl model.key (Url.toString url)
                    in
                    ( model, command )

                Browser.External url ->
                    ( model, Nav.load url )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


notFoundPage : Html Msg
notFoundPage =
    div []
        [ div [] [ text "Page not found!" ]
        , a [ href "/" ] [ text "Take me back to home" ]
        ]


homePage : Html Msg
homePage =
    div []
        [ div [] [ text "This is the homepage" ]
        , a [ href "/notfoundpage" ] [ text "go to a 404 page" ]
        , br [] []
        , a [ href "/posts" ] [ text "Posts page" ]
        ]


routeView : Model -> Html Msg
routeView model =
    case model.page of
        NotFoundPage ->
            notFoundPage

        HomePage ->
            homePage

        PostsPage postsModel ->
            PostsOne.view postsModel


view : Model -> Browser.Document Msg
view model =
    { title = "My Routing App"
    , body = [ routeView model ]
    }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
