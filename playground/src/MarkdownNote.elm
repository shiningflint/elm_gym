module MarkdownNote exposing (main)

import Browser
import Css
    exposing
        ( auto
        , backgroundColor
        , borderStyle
        , bottom
        , calc
        , column
        , displayFlex
        , fixed
        , flexDirection
        , fontFamilies
        , hex
        , margin4
        , maxWidth
        , minHeight
        , minus
        , none
        , padding
        , pct
        , position
        , preLine
        , px
        , resize
        , right
        , vertical
        , whiteSpace
        , width
        )
import Css.Global exposing (body, global, typeSelector)
import File.Download as Download
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
    | DownloadDoc


saveDoc : String -> Cmd Msg
saveDoc markdown =
    Download.string "banana-doc.md" "text/markdown" markdown


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateDocContent val ->
            ( { model | doc = Doc val }, Cmd.none )

        ToPreview ->
            ( { model | docView = Preview }, Cmd.none )

        ToEdit ->
            ( { model | docView = Edit }, Cmd.none )

        DownloadDoc ->
            ( model, encodeDoc model.doc |> saveDoc )



-- VIEW


bodyBgColor : String
bodyBgColor =
    "2b323a"


contentBgColor : String
contentBgColor =
    "e6e5e5"


baseFontFamilies : List String
baseFontFamilies =
    [ "Arial", "Helvetica", "sans-serif" ]


docContentStyle : Attribute msg
docContentStyle =
    let
        paddingSpace =
            16
    in
    css
        [ resize vertical
        , Css.width <|
            calc (pct 100) minus <|
                px (paddingSpace * 2)
        , minHeight (px 500)
        , borderStyle none
        , padding (px paddingSpace)
        , fontFamilies baseFontFamilies
        , backgroundColor (hex contentBgColor)
        ]


styledTextArea model =
    textarea
        [ value (encodeDoc model.doc)
        , onInput UpdateDocContent
        , docContentStyle
        ]
        []


styledDocPreview : Doc -> Html Msg
styledDocPreview doc =
    div [ docContentStyle ] <|
        List.map (\h -> Html.Styled.fromUnstyled h) <|
            Markdown.toHtml Nothing (encodeDoc doc)


globalStyleNode : Html Msg
globalStyleNode =
    global
        [ body
            [ backgroundColor (hex bodyBgColor)
            , fontFamilies baseFontFamilies
            ]
        , typeSelector "pre" [ whiteSpace preLine ]
        ]


docViewContent : Model -> Html Msg
docViewContent model =
    case model.docView of
        Edit ->
            styledTextArea model

        Preview ->
            styledDocPreview model.doc


editPreviewButton docView =
    case docView of
        Edit ->
            button
                [ type_ "button"
                , onClick ToPreview
                ]
                [ text "Preview" ]

        Preview ->
            button
                [ type_ "button"
                , onClick ToEdit
                ]
                [ text "Edit" ]


controlPanel : Model -> Html Msg
controlPanel model =
    div
        [ css
            [ position fixed
            , bottom (px 16)
            , right (px 16)
            , displayFlex
            , flexDirection column
            ]
        ]
        [ button
            [ type_ "button"
            , onClick DownloadDoc
            ]
            [ text "Download document" ]
        , editPreviewButton model.docView
        ]


view : Model -> Html.Html Msg
view model =
    div []
        [ globalStyleNode
        , div
            [ css
                [ maxWidth (px 600)
                , margin4 (px 64) auto (px 0) auto
                ]
            ]
            [ docViewContent model ]
        , controlPanel model
        ]
        |> Html.Styled.toUnstyled


init : () -> ( Model, Cmd Msg )
init _ =
    ( { doc = Doc "# Title"
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
