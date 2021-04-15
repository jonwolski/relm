module Route exposing (Route(..), parseUrl, pushUrl, toString)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | Home
--  | Posts
--  | Post PostId
--  | NewPost
--  | EditPost PostId


pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    Nav.pushUrl navKey <| toString route


parseUrl : Url -> Route
parseUrl url =
   case parse matchRoute url of
       Just route -> route
       Nothing -> NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Home top
--      , map Posts (s "posts")
--      , map NewPost (s "posts" </> s "new")
--      , map Post (s "posts" </> s "id")
        ]


toString : Route -> String
toString route =
    case route of
        NotFound ->
            "Not Found"

        Home ->
            "Home"

