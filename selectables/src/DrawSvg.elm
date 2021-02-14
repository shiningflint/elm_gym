module DrawSvg exposing (draw)

import DrawItem
import Html exposing (Html)
import List.Extra
import Set exposing (Set)
import Svg exposing (Svg)
import Svg.Events
import SvgParser exposing (Element, SvgAttribute, SvgNode(..))



-- MAIN API


draw :
    String
    -> DrawItem.Selectables
    -> (DrawItem.ValueId -> msg)
    -> Html msg
draw svgString selectables toMsg =
    stringToSvg svgString selectables toMsg


stringToSvg :
    String
    -> DrawItem.Selectables
    -> (DrawItem.ValueId -> msg)
    -> Svg msg
stringToSvg svgString selectables toMsg =
    case SvgParser.parseToNode svgString of
        Ok sn ->
            nodeToClickableSvg sn selectables toMsg

        Err e ->
            Svg.text <| "error: " ++ e



-- SEAT COLOR


setFillColor : SvgAttribute -> String -> SvgAttribute
setFillColor ( n, v ) seatColor =
    if n == "fill" then
        ( n, seatColor )

    else
        ( n, v )


wireFillColor :
    DrawItem.DrawId
    -> DrawItem.Selectables
    -> List SvgAttribute
    -> List SvgAttribute
wireFillColor drawIdValue selectables elAttrs =
    let
        seatColor =
            DrawItem.getSeatState drawIdValue selectables.selected selectables.disabled
                |> DrawItem.getSeatColor
    in
    case List.Extra.find (\( n, v ) -> n == "fill") elAttrs of
        Nothing ->
            elAttrs ++ [ ( "fill", seatColor ) ]

        Just el ->
            List.map
                (\( n, v ) -> setFillColor ( n, v ) seatColor)
                elAttrs



-- SVG NODE OPERATION


hasDrawIdValue :
    SvgAttribute
    -> List DrawItem.DrawId
    -> Bool
hasDrawIdValue ( name, value ) selectableIds =
    name == "id" && List.member value selectableIds


seatedAttributes :
    DrawItem.Selectables
    -> List SvgAttribute
    -> List SvgAttribute
seatedAttributes selectables elAttrs =
    case List.Extra.find (\( n, v ) -> hasDrawIdValue ( n, v ) selectables.selectableIds) elAttrs of
        Nothing ->
            elAttrs

        Just el ->
            List.filter (\( n, v ) -> n /= "style") elAttrs
                |> wireFillColor (Tuple.second el) selectables


clickableAttribute :
    List SvgAttribute
    -> DrawItem.Selectables
    -> (DrawItem.DrawId -> msg)
    -> List (Svg.Attribute msg)
clickableAttribute elAttrs selectables toMsg =
    case List.Extra.find (\( n, v ) -> hasDrawIdValue ( n, v ) selectables.selectableIds) elAttrs of
        Nothing ->
            []

        Just ( name, value ) ->
            let
                seatState =
                    DrawItem.getSeatState value selectables.selected selectables.disabled
            in
            if DrawItem.isThisSeatTaken seatState then
                []

            else
                [ Svg.Events.onClick (toMsg value) ]


elementToClickableSvg :
    Element
    -> DrawItem.Selectables
    -> (DrawItem.ValueId -> msg)
    -> Svg msg
elementToClickableSvg element selectables toMsg =
    Svg.node element.name
        ((seatedAttributes selectables element.attributes
            |> List.map SvgParser.toAttribute
         )
            ++ clickableAttribute element.attributes selectables toMsg
        )
        (List.map
            (\svgNode -> nodeToClickableSvg svgNode selectables toMsg)
            element.children
        )


nodeToClickableSvg :
    SvgNode
    -> DrawItem.Selectables
    -> (DrawItem.ValueId -> msg)
    -> Svg msg
nodeToClickableSvg svgNode selectables toMsg =
    case svgNode of
        SvgElement element ->
            elementToClickableSvg element selectables toMsg

        SvgText content ->
            Svg.text content

        SvgComment content ->
            Svg.text ""
