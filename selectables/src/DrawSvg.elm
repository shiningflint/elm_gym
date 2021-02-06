module DrawSvg exposing (draw)

import DrawItem
import Html exposing (Html)
import List.Extra
import Svg exposing (Svg)
import SvgParser exposing (Element, SvgAttribute, SvgNode(..))


draw : String -> List DrawItem.DrawId -> Html msg
draw svgString drawIds =
    stringToSvg svgString


stringToSvg : String -> Svg msg
stringToSvg svgString =
    case SvgParser.parseToNode svgString of
        Ok sn ->
            nodeToClickableSvg sn

        Err e ->
            Svg.text <| "error: " ++ e



-- SVG NODE OPERATION


hasDrawIdValue : SvgAttribute -> Bool
hasDrawIdValue ( name, value ) =
    name == "id" && List.member value DrawItem.drawIds


hasFill : SvgAttribute -> Bool
hasFill ( name, value ) =
    name == "fill"


setFillColor : SvgAttribute -> SvgAttribute
setFillColor ( name, value ) =
    if name == "fill" then
        ( name, "#FF0000" )

    else
        ( name, value )


wireFillColor : List SvgAttribute -> DrawItem.DrawId -> List SvgAttribute
wireFillColor elAttrs drawIdValue =
    -- find fill color
    -- if found, set fill value to red
    -- if not found, append fill color with red
    case List.Extra.find hasFill elAttrs of
        Nothing ->
            elAttrs ++ [ ( "fill", "#FF0000" ) ]

        Just el ->
            List.map setFillColor elAttrs


seatedAttributes : List SvgAttribute -> List SvgAttribute
seatedAttributes elAttrs =
    case List.Extra.find hasDrawIdValue elAttrs of
        Nothing ->
            elAttrs

        Just el ->
            -- if seated element is found
            -- change the fill attribute color to red
            wireFillColor elAttrs (Tuple.second el)


elementToClickableSvg : Element -> Svg msg
elementToClickableSvg element =
    Svg.node element.name
        (List.map SvgParser.toAttribute <| seatedAttributes element.attributes)
        (List.map nodeToClickableSvg element.children)


nodeToClickableSvg : SvgNode -> Svg msg
nodeToClickableSvg svgNode =
    case svgNode of
        SvgElement element ->
            elementToClickableSvg element

        SvgText content ->
            Svg.text content

        SvgComment content ->
            Svg.text ""
