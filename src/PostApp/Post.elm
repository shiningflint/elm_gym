module PostApp.Post exposing (Post, postDecoder, postsDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)


type alias Post =
    { id : Int
    , title : String
    , author : String
    }


postsDecoder : Decoder (List Post)
postsDecoder =
    list postDecoder


postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" int
        |> required "title" string
        |> required "author" string
