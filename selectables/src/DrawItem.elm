module DrawItem exposing
    ( DrawId
    , DrawItem
    , ValueId
    , drawIds
    , drawItems
    , isThisSeatTaken
    , selectedValueIds
    )

import List.Extra
import Set exposing (Set)


type alias DrawItem =
    { drawId : DrawId
    , valueId : ValueId
    }


type alias DrawId =
    String


type alias ValueId =
    String


isThisSeatTaken : DrawId -> ( List DrawItem, Set ValueId ) -> Bool
isThisSeatTaken drawIdValue selectables =
    case List.Extra.find (\di -> drawIdValue == di.drawId) (Tuple.first selectables) of
        Nothing ->
            False

        Just di ->
            Set.member di.valueId (Tuple.second selectables)


drawItems : List DrawItem
drawItems =
    [ { drawId = "seat01", valueId = "1A" }
    , { drawId = "seat02", valueId = "1B" }
    , { drawId = "seat03", valueId = "2A" }
    , { drawId = "seat04", valueId = "2B" }

    -- , { drawId = "seat05", valueId = "3A" }
    -- , { drawId = "seat06", valueId = "3B" }
    ]


selectedValueIds : Set ValueId
selectedValueIds =
    Set.fromList [ "1B", "1A", "2A" ]


drawIds : List DrawId
drawIds =
    [ "seat01"
    , "seat02"
    , "seat03"
    , "seat04"
    ]
