-- 1. Parse svg into Html msg
-- 2. If done, try to pass that to one more function adding onClick msg


module SvgParserTest exposing (main)

import Browser
import Html exposing (..)
import List.Extra
import Svg exposing (Attribute, Svg)
import Svg.Attributes as Sattr
import Svg.Events as Sevent
import SvgParser exposing (Element, SvgAttribute, SvgNode(..))
import VirtualDom


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { svgString : String
    }


init : Model
init =
    { svgString = generateSvgString }



-- UPDATE


type Msg
    = ToggleCheckbox


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleCheckbox ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ embedSvg model.svgString ]


embedSvg : String -> Html Msg
embedSvg svgString =
    Svg.svg
        [ Sattr.viewBox "-0.5 -0.5 181 181"
        , Sattr.width "181px"
        , Sattr.height "181px"
        ]
        [ stringToSvg svgString ]


stringToSvg : String -> Svg Msg
stringToSvg svgString =
    case SvgParser.parseToNode svgString of
        Ok sn ->
            nodeToClickableSvg sn

        Err e ->
            Svg.text <| "error: " ++ e



-- SVG PARSER EXTRA


findClickableAttribute : List SvgAttribute -> Maybe SvgAttribute
findClickableAttribute elementAttributes =
    List.Extra.find (\( name, value ) -> name == "id" && value == "seat01") elementAttributes


onClickAttribute : Maybe SvgAttribute -> List (Svg.Attribute Msg)
onClickAttribute maybeClickAttribute =
    case maybeClickAttribute of
        Nothing ->
            []

        Just ca ->
            [ Sevent.onClick ToggleCheckbox ]


elementToClickableSvg : Element -> Svg Msg
elementToClickableSvg element =
    Svg.node element.name
        (List.map SvgParser.toAttribute element.attributes
            ++ onClickAttribute (findClickableAttribute element.attributes)
        )
        (List.map nodeToClickableSvg element.children)


nodeToClickableSvg : SvgNode -> Svg Msg
nodeToClickableSvg svgNode =
    case svgNode of
        SvgElement element ->
            elementToClickableSvg element

        SvgText content ->
            Svg.text content

        SvgComment content ->
            Svg.text ""



-- EXPERIMENTAL FEATURES


blackFill : SvgNode -> SvgNode
blackFill sn =
    case sn of
        SvgElement sel ->
            let
                newChildren =
                    \c ->
                        case c of
                            SvgElement csel ->
                                SvgElement { csel | attributes = updateSvgAttributeColor csel.attributes "#000000" }

                            _ ->
                                c
            in
            SvgElement { sel | children = List.map newChildren sel.children }

        _ ->
            sn


updateSvgAttributeColor : List SvgAttribute -> String -> List SvgAttribute
updateSvgAttributeColor attrs color =
    let
        mapAttr =
            \a ->
                if Tuple.first a == "fill" then
                    ( Tuple.first a, color )

                else
                    a
    in
    List.map mapAttr attrs



-- SVG INPUT


generateSvgString : String
generateSvgString =
    """<g><rect id="seat01" x="0" y="0" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect x="0" y="100" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect x="100" y="0" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect x="100" y="100" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /></g>"""
