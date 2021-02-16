module DrawItem exposing
    ( DrawId
    , DrawItem
    , SeatState
    , Selectables
    , ValueId
    , getSeatColor
    , getSeatState
    , getValueId
    , isThisSeatTaken
    , notMaxed
    , toggleSelected
    )

import List.Extra
import Set exposing (Set)



-- DrawItem is not being used right now


type alias DrawItem =
    { drawId : DrawId
    , valueId : ValueId
    }


type alias Selectables =
    { selectableIds : List DrawId
    , selected : Set DrawId
    , disabled : Set DrawId
    , maxSelection : Int
    }


type alias DrawId =
    String


type alias ValueId =
    String


type SeatState
    = Selected
    | Untaken
    | Taken



-- SEAT TYPE LOGIC


getSeatState : DrawId -> Set DrawId -> Set DrawId -> SeatState
getSeatState drawIdValue set disabled =
    if Set.member drawIdValue disabled then
        Taken

    else if Set.member drawIdValue set then
        Selected

    else
        Untaken


getSeatColor : SeatState -> String
getSeatColor seatState =
    case seatState of
        Selected ->
            "#BD2F2F"

        Untaken ->
            "#8DC5A4"

        Taken ->
            "#8E8E8E"


isThisSeatTaken : SeatState -> Bool
isThisSeatTaken seatState =
    case seatState of
        Taken ->
            True

        _ ->
            False



-- SELECTION LOGIC


toggleSelected : DrawId -> Set DrawId -> Int -> Set DrawId
toggleSelected valueId selected maxSelection =
    if Set.member valueId selected then
        Set.remove valueId selected

    else if notMaxed selected maxSelection then
        Set.insert valueId selected

    else
        selected


notMaxed : Set DrawId -> Int -> Bool
notMaxed selected maxSelection =
    Set.size selected < maxSelection


getValueId : DrawId -> List DrawItem -> Maybe DrawItem
getValueId drawIdValue drawItemValues =
    List.Extra.find (\di -> drawIdValue == di.drawId) drawItemValues
