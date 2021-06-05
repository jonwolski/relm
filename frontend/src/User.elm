module User exposing (User, decoder)

import Json.Decode exposing (Decoder, nullable, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias User =
    { email : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    , token : String
    }


decoder : Decoder User
decoder =
    succeed User
        |> required "email" string
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" (nullable string)
        |> required "token" string
