module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Page.ListPosts as ListPosts
import Route exposing (Route, parseUrl)
import Url exposing (Url)


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }



-- Page is being examined by view to determine which view to load


type Page
    = NotFoundPage
    | NotAsked
    | ListPage ListPosts.Model


type Msg
    = ListPageMsg ListPosts.Msg
    | UrlChanged Url
    | LinkClicked UrlRequest



-- initCurrentPage: Takes the route, and updates the page accordingly
-- model.page is just containing the model of that page


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Posts ->
                    let
                        ( pageModel, pageCmds ) =
                            ListPosts.init
                    in
                    ( ListPage pageModel, Cmd.map ListPageMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotAsked
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )


view : Model -> Document Msg
view model =
    case model.page of
        NotFoundPage ->
            notFoundView

        NotAsked ->
            notAskedView

        ListPage pageModel ->
            -- ListPosts.view pageModel
            -- |> Html.map ListPageMsg
            { title = "List posts"
            , body = [ h3 [] [ text "got list of posts" ] ]
            }


notFoundView : Document Msg
notFoundView =
    { title = "404 Not Found"
    , body = [ h3 [] [ text "Oops, this page flew away" ] ]
    }


notAskedView : Document Msg
notAskedView =
    { title = "Welcome to the post page!"
    , body =
        [ h3 [] [ text "Welcome to the post page!" ]
        , p [] [ text "Click the load button to load posts" ]
        , p [] [ button [] [ text "load posts!" ] ]
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ListPageMsg subMsg, ListPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ListPosts.update subMsg pageModel
            in
            ( { model | page = ListPage updatedPageModel }
            , Cmd.map ListPageMsg updatedCmd
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

        ( _, _ ) ->
            ( model, Cmd.none )


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
