module DrawItem exposing
    ( DrawId
    , DrawItem
    , ValueId
    , getValueId
    , isThisSeatTaken
    )

import List.Extra
import Set exposing (Set)



-- DrawItem is not being used right now


type alias DrawItem =
    { drawId : DrawId
    , valueId : ValueId
    }


type alias DrawId =
    String


type alias ValueId =
    String


isThisSeatTaken : DrawId -> Set DrawId -> Bool
isThisSeatTaken drawIdValue set =
    Set.member drawIdValue set


getValueId : DrawId -> List DrawItem -> Maybe DrawItem
getValueId drawIdValue drawItemValues =
    List.Extra.find (\di -> drawIdValue == di.drawId) drawItemValues
