module Pipe exposing (greeting, joinName)


greeting : String -> String
greeting name =
    "Hello " ++ name


joinName : String -> String -> String
joinName fn ln =
    fn ++ ln
