module LessMore exposing
    (  Friend(..)
       -- , getFriendInfo

    , createFriend
    , tom
    )


type alias Info =
    { age : Int
    }


type Friend
    = Less String
    | More String Info


tom =
    Less "Tom"


createFriend constructor name moreData =
    constructor name moreData



-- getFriendInfo friend =
--     case friend of
--         Less name ->
--             { name = name }
--         More name info ->
--             { name = name, age = info.age }
