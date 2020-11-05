module Doc exposing (Doc(..), encode, initDoc)


type Doc
    = Doc String


initDoc : Doc
initDoc =
    Doc "# Titlee"


encode : Doc -> String
encode doc =
    case doc of
        Doc content ->
            content
