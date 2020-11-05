module Main exposing (main)

import Browser
import Css exposing (..)
import Css.Global exposing (body, global, selector, typeSelector)
import Css.Transitions as Transitions
import Doc exposing (Doc(..))
import File.Download as Download
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Markdown



-- MODEL


type DocView
    = Edit
    | Preview


type AppTheme
    = Theme1
    | Theme2


type alias Model =
    { doc : Doc
    , docView : DocView
    , docFilename : String
    , appTheme : AppTheme
    , showDialog : Bool
    , showControlPanel : Bool
    }



-- UPDATE


type Msg
    = UpdateDocContent String
    | ToPreview
    | ToEdit
    | SwitchToThemeA
    | SwitchToThemeB
    | ToggleDownloadDocDialog
    | ToggleControlPanel
    | DownloadDoc
    | UpdateFileName String
    | NoOp


saveDoc : String -> String -> Cmd Msg
saveDoc filename markdown =
    Download.string (filename ++ ".md") "text/markdown" markdown


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateDocContent val ->
            ( { model | doc = Doc val }, Cmd.none )

        ToPreview ->
            ( { model | docView = Preview }, Cmd.none )

        ToEdit ->
            ( { model | docView = Edit }, Cmd.none )

        SwitchToThemeA ->
            ( { model | appTheme = Theme1 }, Cmd.none )

        SwitchToThemeB ->
            ( { model | appTheme = Theme2 }, Cmd.none )

        ToggleDownloadDocDialog ->
            let
                updatedBool =
                    not model.showDialog
            in
            ( { model | showDialog = updatedBool }, Cmd.none )

        ToggleControlPanel ->
            let
                updatedBool =
                    not model.showControlPanel
            in
            ( { model | showControlPanel = updatedBool }, Cmd.none )

        DownloadDoc ->
            ( model, Doc.encode model.doc |> saveDoc model.docFilename )

        UpdateFileName name ->
            ( { model | docFilename = name }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



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
        [ resize none
        , Css.width <|
            calc (pct 100) minus <|
                px (paddingSpace * 2)
        , Css.height <|
            calc (pct 100) minus <|
                px (paddingSpace * 2)
        , borderStyle none
        , padding (px paddingSpace)
        , margin (px 0)
        , fontFamilies baseFontFamilies
        , backgroundColor (hex contentBgColor)
        , overflowY scroll
        ]


styledTextArea model =
    textarea
        [ value (Doc.encode model.doc)
        , onInput UpdateDocContent
        , docContentStyle
        ]
        []


styledDocPreview : Doc -> Html Msg
styledDocPreview doc =
    div [ docContentStyle ] <|
        List.map (\h -> Html.Styled.fromUnstyled h) <|
            Markdown.toHtml Nothing (Doc.encode doc)


globalStyleNode : AppTheme -> Html Msg
globalStyleNode theme =
    let
        content =
            case theme of
                Theme1 ->
                    [ body
                        [ backgroundColor (hex bodyBgColor)
                        , fontFamilies baseFontFamilies
                        ]
                    , selector "body > div"
                        [ Css.height (vh 100)
                        , Css.width (vw 100)
                        ]
                    , typeSelector "pre" [ whiteSpace preLine ]
                    ]

                Theme2 ->
                    [ body
                        [ backgroundColor (hex "fefefe")
                        , fontFamilies baseFontFamilies
                        ]
                    , selector "body > div"
                        [ Css.height (vh 100)
                        , Css.width (vw 100)
                        ]
                    , typeSelector "pre" [ whiteSpace preLine ]
                    ]
    in
    global content


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


controlPanelToggleButton =
    button
        [ type_ "button"
        , onClick ToggleControlPanel
        , css
            [ position absolute
            , top (pct 50)
            , translateY (pct -50) |> transform
            , left (px -50)
            ]
        ]
        [ text "x"
        ]


controlPanel : Model -> Html Msg
controlPanel model =
    let
        toggleDisplay =
            if model.showControlPanel then
                translateX (px 0) |> transform

            else
                translateX (px 160) |> transform
    in
    div
        [ css
            [ position fixed
            , top (pct 50)
            , right (px 16)
            , displayFlex
            , flexDirection column
            , toggleDisplay
            , Transitions.transition
                [ Transitions.transform 200
                ]
            ]
        ]
        [ editPreviewButton model.docView
        , button
            [ type_ "button"
            , onClick ToggleDownloadDocDialog
            ]
            [ text "Download document" ]

        -- , button [ onClick SwitchToThemeA ] [ text "Theme A" ]
        -- , button [ onClick SwitchToThemeB ] [ text "Theme B" ]
        , controlPanelToggleButton
        ]


onClickNoBubble : Msg -> Attribute Msg
onClickNoBubble message =
    Html.Styled.Events.custom "click" (Decode.succeed { message = message, stopPropagation = True, preventDefault = True })


fileDialog : Model -> Html Msg
fileDialog model =
    div
        [ onClick ToggleDownloadDocDialog
        , css
            [ backgroundColor (hex "2b323ab3")
            , displayFlex
            , justifyContent center
            , alignItems center
            , position fixed
            , top (px 0)
            , bottom (px 0)
            , right (px 0)
            , left (px 0)
            ]
        ]
        [ div
            [ onClickNoBubble NoOp
            , css
                [ backgroundColor (hex contentBgColor)
                ]
            ]
            [ input [ onInput UpdateFileName, value model.docFilename ] []
            , br [] []
            , button [ type_ "button", onClick ToggleDownloadDocDialog ]
                [ text "x" ]
            , button [ onClick DownloadDoc ] [ text "Download as markdown" ]
            ]
        ]


view : Model -> Html.Html Msg
view model =
    div []
        [ globalStyleNode model.appTheme
        , docViewContent model
        , controlPanel model
        , if model.showDialog then
            fileDialog model

          else
            Html.Styled.text ""
        ]
        |> Html.Styled.toUnstyled


init : () -> ( Model, Cmd Msg )
init _ =
    ( { doc = Doc.initDoc
      , docView = Edit
      , docFilename = "Untitled"
      , showDialog = False
      , showControlPanel = True
      , appTheme = Theme1
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
