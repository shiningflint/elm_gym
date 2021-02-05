-- 1. Parse svg into Html msg
-- 2. If done, try to pass that to one more function adding onClick msg


module HtmlParser exposing (main)

import Browser
import Html exposing (..)
import Svg exposing (Svg)
import Svg.Attributes as Sattr
import SvgParser exposing (SvgAttribute, SvgNode(..))


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


update : msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Html msg
view model =
    div [] [ embedSvg model.svgString ]


embedSvg : String -> Html msg
embedSvg svgString =
    Svg.svg
        [ Sattr.viewBox "-0.5 -0.5 181 181"
        , Sattr.width "181px"
        , Sattr.height "181px"
        ]
        [ stringToSvg svgString ]


stringToSvg : String -> Svg msg
stringToSvg svgString =
    case SvgParser.parseToNode svgString of
        Ok sn ->
            SvgParser.nodeToSvg sn

        Err e ->
            Svg.text <| "error: " ++ e



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
    """<g><rect x="0" y="0" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect x="0" y="100" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect x="100" y="0" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /><rect x="100" y="100" width="80" height="80" fill="#999999" stroke="#000000" pointer-events="all" /></g>"""
