module Page.Post exposing
    ( Model
    , Msg
    , Post
    , PostId
    , idParser
    , idToString
    , init
    , postsResponseDecoder
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (class, datetime, property)
import Html.Events exposing (onClick)
import Http
import Iso8601 exposing (fromTime)
import Json.Decode as Decode exposing (Decoder, Error(..), bool, field, int, list, nullable, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (RemoteData, WebData)
import Time
import Url.Builder exposing (absolute)
import Url.Parser exposing (Parser, custom)


type PostId
    = PostId String


idToString : PostId -> String
idToString (PostId s) =
    s


idParser : Parser (PostId -> a) a
idParser =
    custom "POSTID" <| Just << PostId


type alias Model =
    { navKey : Nav.Key
    , postId : PostId
    , post : WebData Post
    }


type alias Author =
    { username : String
    , bio : Maybe String
    , image : String
    , following : Bool
    }


type alias Post =
    { title : String
    , slug : String
    , body : String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , tagList : List String
    , description : String
    , author : Author
    , favorited : Bool
    , favoritesCount : Int
    }


postResponseDecoder : Decoder Post
postResponseDecoder =
    field "article" postDecoder


postsResponseDecoder : Decoder (List Post)
postsResponseDecoder =
    field "articles" (list postDecoder)


postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "title" string
        |> required "slug" string
        |> required "body" string
        |> required "createdAt" Iso8601.decoder
        |> required "updatedAt" Iso8601.decoder
        |> required "tagList" (list string)
        |> required "description" string
        |> required "author" authorDecoder
        |> required "favorited" bool
        |> required "favoritesCount" int


authorDecoder : Decoder Author
authorDecoder =
    Decode.succeed Author
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" string
        |> required "following" bool


init : PostId -> Nav.Key -> ( Model, Cmd Msg )
init postId navKey =
    let
        slug =
            idToString postId
    in
    ( initialModel postId navKey, getPost slug )


initialModel : PostId -> Nav.Key -> Model
initialModel postId navKey =
    { navKey = navKey
    , postId = postId
    , post = RemoteData.Loading
    }



-- VIEW


view : Model -> Html Msg
view model =
    case model.post of
        RemoteData.NotAsked ->
            let
                slug =
                    idToString model.postId
            in
            div [ class "container" ]
                [ button [ onClick <| GetPost slug ]
                    [ text <| "Load Post " ++ slug ]
                ]

        RemoteData.Loading ->
            div [ class "container" ]
                [ text "Loading ..." ]

        RemoteData.Failure error ->
            div [ class "container" ]
                [ text <| buildErrorMessage error ]

        RemoteData.Success post ->
            div [ class "container" ]
                [ viewPost post ]


viewPost : Post -> Html Msg
viewPost post =
    div [ class "container" ]
        [ h1 [ class "logo-font" ]
            [ text post.title ]
        , cite [] [ text post.author.username ]
        , div [ class "publishedDate" ]
            [ text "Last updated at"
            , Html.time [ datetime <| fromTime post.updatedAt ]
                [ text <| fromTime post.updatedAt ]
            ]
        , div [] [ text post.body ]
        ]


type Msg
    = GetPost String
    | PostReceived (WebData Post)



-- UPDATE


getPost : String -> Cmd Msg
getPost slug =
    Http.get
        { url = "https://conduit.productionready.io/api/articles/" ++ slug
        , expect =
            postResponseDecoder
                |> Http.expectJson (RemoteData.fromResult >> PostReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetPost slug ->
            ( { model | post = RemoteData.Loading }, getPost slug )

        PostReceived post ->
            ( { model | post = post }, Cmd.none )
