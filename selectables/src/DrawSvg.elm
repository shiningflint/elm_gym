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
    -> ( List DrawItem.DrawId, Set DrawItem.DrawId )
    -> (DrawItem.ValueId -> msg)
    -> Html msg
draw svgString selectables toMsg =
    stringToSvg svgString selectables toMsg


stringToSvg :
    String
    -> ( List DrawItem.DrawId, Set DrawItem.DrawId )
    -> (DrawItem.ValueId -> msg)
    -> Svg msg
stringToSvg svgString selectables toMsg =
    case SvgParser.parseToNode svgString of
        Ok sn ->
            nodeToClickableSvg sn selectables toMsg

        Err e ->
            Svg.text <| "error: " ++ e



-- SEAT


type SeatState
    = Taken
    | Untaken


getSeatState :
    DrawItem.DrawId
    -> Set DrawItem.DrawId
    -> SeatState
getSeatState drawIdValue set =
    case DrawItem.isThisSeatTaken drawIdValue set of
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
    -> ( List DrawItem.DrawId, Set DrawItem.DrawId )
    -> List SvgAttribute
    -> List SvgAttribute
wireFillColor drawIdValue selectables elAttrs =
    let
        seatColor =
            getSeatState drawIdValue (Tuple.second selectables)
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
    ( List DrawItem.DrawId, Set DrawItem.DrawId )
    -> List SvgAttribute
    -> List SvgAttribute
seatedAttributes selectables elAttrs =
    case List.Extra.find (\( n, v ) -> hasDrawIdValue ( n, v ) (Tuple.first selectables)) elAttrs of
        Nothing ->
            elAttrs

        Just el ->
            List.filter (\( n, v ) -> n /= "style") elAttrs
                |> wireFillColor (Tuple.second el) selectables


clickableAttribute :
    List SvgAttribute
    -> ( List DrawItem.DrawId, Set DrawItem.DrawId )
    -> (DrawItem.DrawId -> msg)
    -> List (Svg.Attribute msg)
clickableAttribute elAttrs selectables toMsg =
    case List.Extra.find (\( n, v ) -> hasDrawIdValue ( n, v ) (Tuple.first selectables)) elAttrs of
        Nothing ->
            []

        Just ( name, value ) ->
            [ Svg.Events.onClick (toMsg value) ]


elementToClickableSvg :
    Element
    -> ( List DrawItem.DrawId, Set DrawItem.DrawId )
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
    -> ( List DrawItem.DrawId, Set DrawItem.DrawId )
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
