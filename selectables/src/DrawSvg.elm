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



-- SEAT STYLING


setAttributeValue : SvgAttribute -> String -> String -> SvgAttribute
setAttributeValue ( n, v ) attrName attrValue =
    if n == attrName then
        ( n, attrValue )

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
                (\( n, v ) -> setAttributeValue ( n, v ) "fill" seatColor)
                elAttrs


maxedSeat :
    DrawItem.DrawId
    -> Set DrawItem.DrawId
    -> Int
    -> List SvgAttribute
    -> List SvgAttribute
maxedSeat drawIdValue selected maxSelection elAttrs =
    let
        transparent =
            "0.5"

        maxedSeatAttrs =
            case List.Extra.find (\( n, v ) -> n == "opacity") elAttrs of
                Nothing ->
                    elAttrs ++ [ ( "opacity", transparent ) ]

                Just el ->
                    List.map
                        (\( n, v ) -> setAttributeValue ( n, v ) "opacity" transparent)
                        elAttrs
    in
    if
        DrawItem.notMaxed selected maxSelection
            || Set.member drawIdValue selected
    then
        elAttrs

    else
        maxedSeatAttrs



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
            let
                drawIdValue =
                    Tuple.second el
            in
            List.filter (\( n, v ) -> n /= "style") elAttrs
                |> maxedSeat drawIdValue selectables.selected selectables.maxSelection
                |> wireFillColor drawIdValue selectables


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
