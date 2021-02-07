module DrawSvg exposing (draw)

import DrawItem
import Html exposing (Html)
import List.Extra
import Set exposing (Set)
import Svg exposing (Svg)
import SvgParser exposing (Element, SvgAttribute, SvgNode(..))



-- MAIN API


draw :
    String
    -> List DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> Html msg
draw svgString drawIds selectables =
    stringToSvg svgString selectables


stringToSvg :
    String
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> Svg msg
stringToSvg svgString selectables =
    case SvgParser.parseToNode svgString of
        Ok sn ->
            nodeToClickableSvg sn selectables

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



-- SVG NODE OPERATION


hasDrawIdValue : SvgAttribute -> Bool
hasDrawIdValue ( name, value ) =
    name == "id" && List.member value DrawItem.drawIds


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
    List SvgAttribute
    -> DrawItem.DrawId
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> List SvgAttribute
wireFillColor elAttrs drawIdValue selectables =
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


seatedAttributes :
    List SvgAttribute
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> List SvgAttribute
seatedAttributes elAttrs selectables =
    case List.Extra.find hasDrawIdValue elAttrs of
        Nothing ->
            elAttrs

        Just el ->
            wireFillColor elAttrs (Tuple.second el) selectables


elementToClickableSvg :
    Element
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> Svg msg
elementToClickableSvg element selectables =
    Svg.node element.name
        (List.map SvgParser.toAttribute <|
            seatedAttributes element.attributes selectables
        )
        (List.map
            (\svgNode -> nodeToClickableSvg svgNode selectables)
            element.children
        )


nodeToClickableSvg :
    SvgNode
    -> ( List DrawItem.DrawItem, Set DrawItem.ValueId )
    -> Svg msg
nodeToClickableSvg svgNode selectables =
    case svgNode of
        SvgElement element ->
            elementToClickableSvg element selectables

        SvgText content ->
            Svg.text content

        SvgComment content ->
            Svg.text ""
