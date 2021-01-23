module User exposing
    ( Form
    , User
    , decoder
    , email
    , emptyForm
    , formToUser
    , id
    , idString
    , json
    , listDecoder
    , updateForm
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode



-- TYPES


type User
    = User Internals


type alias Internals =
    { id : Int
    , email : String
    }


type alias Form =
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


json : User -> String
json (User user) =
    let
        value =
            Encode.object
                [ ( "id", Encode.int user.id )
                , ( "email", Encode.string user.email )
                ]
    in
    Encode.encode 0 value



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



-- FORM


emptyForm : Form
emptyForm =
    { id = 0, email = "" }


updateForm : Form -> (Form -> Form) -> Form
updateForm form transform =
    transform form


formToUser : Form -> User
formToUser userForm =
    User userForm
