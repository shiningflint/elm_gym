module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Route
import Url



-- MODEL


type alias Model =
    { route : Route.Route
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        initRoute =
            Route.parseUrl url

        _ =
            Debug.log "url" url
    in
    ( { route = initRoute }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UrlChange
    | UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


onUrlChange : Url.Url -> Msg
onUrlChange url =
    UrlChange


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest urlRequest =
    UrlRequest


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


routeContent : Route.Route -> Html Msg
routeContent route =
    case route of
        Route.NotFound ->
            div [] [ text "404 Not Found" ]

        Route.Top ->
            div [] [ text "This is the top page" ]

        Route.Home ->
            div [] [ text "Welcome home!" ]

        Route.HomeCourses ->
            div [] [ text "Home Courses" ]

        Route.Courses name ->
            div [] [ text <| "Course detail " ++ name ]


view : Model -> Browser.Document Msg
view model =
    { title = "Main title", body = [ routeContent model.route ] }


main =
    Browser.application { init = init, update = update, view = view, onUrlChange = onUrlChange, onUrlRequest = onUrlRequest, subscriptions = subscriptions }
