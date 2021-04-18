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


parseUrl : Maybe String -> Url -> Route
parseUrl rootContext url =
   case parse (matchRoute rootContext) url of
       Just route -> route
       Nothing -> NotFound


matchRoute : Maybe String -> Parser (Route -> a) a
matchRoute maybeRootPathString =
    let
        rootPath = parseRootPath maybeRootPathString
    in
    oneOf
        [ map Home rootPath
--      , map Posts (rootPath </> s "posts")
--      , map NewPost (rootPath </> s "posts" </> s "new")
--      , map Post (rootPath </> s "posts" </> s "id")
        ]


parseRootPath : Maybe String -> Parser a a
parseRootPath maybeRootPathString =
    case maybeRootPathString of
        Just path -> s path
        Nothing -> top


toString : Route -> String
toString route =
    case route of
        NotFound ->
            "Not Found"

        Home ->
            "Home"

