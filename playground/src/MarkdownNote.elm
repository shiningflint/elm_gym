module MarkdownNote exposing (main)

import Browser
import Css
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick, onInput)
import Markdown



-- MODEL


type DocView
    = Edit
    | Preview


type Doc
    = Doc String


encodeDoc : Doc -> String
encodeDoc doc =
    case doc of
        Doc content ->
            content


type alias Model =
    { doc : Doc
    , docView : DocView
    }



-- UPDATE


type Msg
    = UpdateDocContent String
    | ToPreview
    | ToEdit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateDocContent val ->
            ( { model | doc = Doc val }, Cmd.none )

        ToPreview ->
            ( { model | docView = Preview }, Cmd.none )

        ToEdit ->
            ( { model | docView = Edit }, Cmd.none )



-- VIEW


plainTextArea : Model -> Html Msg
plainTextArea model =
    textarea
        [ style "width" "600px"
        , style "height" "300px"
        , value (encodeDoc model.doc)
        , onInput UpdateDocContent
        ]
        []


styledTextArea model =
    textarea
        [ value (encodeDoc model.doc)
        , onInput UpdateDocContent
        ]
        []


docViewContent : Model -> Html Msg
docViewContent model =
    case model.docView of
        Edit ->
            -- plainTextArea model
            styledTextArea model

        Preview ->
            div [] <|
                List.map (\h -> Html.Styled.fromUnstyled h) <|
                    Markdown.toHtml Nothing (encodeDoc model.doc)


view : Model -> Html.Html Msg
view model =
    div []
        [ div []
            [ button
                [ type_ "button"
                , onClick ToEdit
                ]
                [ text "Edit" ]
            , button
                [ type_ "button"
                , onClick ToPreview
                ]
                [ text "Preview" ]
            ]
        , div [] [ docViewContent model ]
        ]
        |> Html.Styled.toUnstyled


init : () -> ( Model, Cmd Msg )
init _ =
    ( { doc = Doc "Kentang bakar panas"
      , docView = Edit
      }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
