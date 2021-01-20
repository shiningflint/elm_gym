module User exposing (User, decoder, email, id, idString, listDecoder)

import Json.Decode as Decode exposing (Decoder)



-- TYPES


type User
    = User Internals


type alias Internals =
    { id : Int
    , email : String
    }



-- INFO


id : User -> Int
id (User user) =
    user.id


idString : User -> String
idString (User user) =
    String.fromInt user.id


email : User -> String
email (User user) =
    user.email



-- SERIALIZATION


idDecoder : Decoder Int
idDecoder =
    Decode.field "id" Decode.int


emailDecoder : Decoder String
emailDecoder =
    Decode.field "email" Decode.string


internalDecoder : Decoder Internals
internalDecoder =
    Decode.map2 Internals idDecoder emailDecoder


decoder : Decoder User
decoder =
    Decode.map User internalDecoder


listDecoder : Decoder (List User)
listDecoder =
    Decode.list decoder
