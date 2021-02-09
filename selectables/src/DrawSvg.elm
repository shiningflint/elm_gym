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
    -> List DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> (DrawItem.ValueId -> msg)
    -> Html msg
draw svgString drawIds selectables toMsg =
    stringToSvg svgString drawIds selectables toMsg


stringToSvg :
    String
    -> List DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> (DrawItem.ValueId -> msg)
    -> Svg msg
stringToSvg svgString drawIds selectables toMsg =
    case SvgParser.parseToNode svgString of
        Ok sn ->
            nodeToClickableSvg sn drawIds selectables toMsg

        Err e ->
            Svg.text <| "error: " ++ e



-- SEAT


type SeatState
    = Taken
    | Untaken


getSeatState :
    DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> SeatState
getSeatState drawIdValue selectables =
    case DrawItem.isThisSeatTaken drawIdValue selectables of
        True ->
            Taken

        False ->
            Untaken


getSeatColor : SeatState -> String
getSeatColor seatState =
    case seatState of
        Taken ->
            "#BD2F2F"

        Untaken ->
            "#8DC5A4"



-- SEAT COLOR


hasFill : SvgAttribute -> Bool
hasFill ( name, value ) =
    name == "fill"


setFillColor : SvgAttribute -> String -> SvgAttribute
setFillColor ( name, value ) seatColor =
    if name == "fill" then
        ( name, seatColor )

    else
        ( name, value )


wireFillColor :
    DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> List SvgAttribute
    -> List SvgAttribute
wireFillColor drawIdValue selectables elAttrs =
    let
        seatColor =
            getSeatState drawIdValue selectables
                |> getSeatColor
    in
    case List.Extra.find hasFill elAttrs of
        Nothing ->
            elAttrs ++ [ ( "fill", seatColor ) ]

        Just el ->
            List.map
                (\( name, value ) -> setFillColor ( name, value ) seatColor)
                elAttrs



-- SVG NODE OPERATION


hasDrawIdValue :
    SvgAttribute
    -> List DrawItem.DrawId
    -> Bool
hasDrawIdValue ( name, value ) drawIds =
    name == "id" && List.member value drawIds


seatedAttributes :
    List DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> List SvgAttribute
    -> List SvgAttribute
seatedAttributes drawIds selectables elAttrs =
    case List.Extra.find (\( n, v ) -> hasDrawIdValue ( n, v ) drawIds) elAttrs of
        Nothing ->
            elAttrs

        Just el ->
            List.filter (\( n, v ) -> n /= "style") elAttrs
                |> wireFillColor (Tuple.second el) selectables


clickableAttribute :
    List SvgAttribute
    -> List DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> (DrawItem.ValueId -> msg)
    -> List (Svg.Attribute msg)
clickableAttribute elAttrs drawIds selectables toMsg =
    case List.Extra.find (\( n, v ) -> hasDrawIdValue ( n, v ) drawIds) elAttrs of
        Nothing ->
            []

        Just el ->
            case DrawItem.getValueId (Tuple.second el) (Tuple.first selectables) of
                Nothing ->
                    []

                Just drawItemValue ->
                    [ Svg.Events.onClick (toMsg drawItemValue.valueId) ]


elementToClickableSvg :
    Element
    -> List DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> (DrawItem.ValueId -> msg)
    -> Svg msg
elementToClickableSvg element drawIds selectables toMsg =
    Svg.node element.name
        ((seatedAttributes drawIds selectables element.attributes
            |> List.map SvgParser.toAttribute
         )
            ++ clickableAttribute element.attributes drawIds selectables toMsg
        )
        (List.map
            (\svgNode -> nodeToClickableSvg svgNode drawIds selectables toMsg)
            element.children
        )


nodeToClickableSvg :
    SvgNode
    -> List DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> (DrawItem.ValueId -> msg)
    -> Svg msg
nodeToClickableSvg svgNode drawIds selectables toMsg =
    case svgNode of
        SvgElement element ->
            elementToClickableSvg element drawIds selectables toMsg

        SvgText content ->
            Svg.text content

        SvgComment content ->
            Svg.text ""
