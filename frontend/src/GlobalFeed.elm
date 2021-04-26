module GlobalFeed exposing (Model, Msg, init, initialModel, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Http
import Iso8601
import Json.Decode as Decode exposing (Decoder, Error(..), bool, field, int, list, nullable, string)
import Json.Decode.Pipeline exposing (required)
import Page.Post as Post exposing (Post, postsResponseDecoder)
import RemoteData exposing (RemoteData, WebData)
import Time
import Url.Builder exposing (absolute)


type alias RootPath =
    Maybe String


type alias Model =
    { posts : WebData (List Post)
    , rootPath : Maybe String
    }


type Msg
    = GetPosts
    | DataReceived (WebData (List Post))


initialModel : Model
initialModel =
    { posts = RemoteData.Loading
    , rootPath = Nothing
    }


init : Maybe String -> ( Model, Cmd Msg )
init rootPath =
    ( { initialModel | rootPath = rootPath }
    , getPosts
    )


getPosts : Cmd Msg
getPosts =
    Http.get
        { url = "https://conduit.productionready.io/api/articles"
        , expect =
            postsResponseDecoder
                |> Http.expectJson (RemoteData.fromResult >> DataReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetPosts ->
            ( { model | posts = RemoteData.Loading }, getPosts )

        DataReceived response ->
            ( { model | posts = response }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ viewPostsRequest model ]


viewPostsRequest : Model -> Html Msg
viewPostsRequest model =
    case model.posts of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            viewLoading

        RemoteData.Failure httpError ->
            viewError httpError

        RemoteData.Success posts ->
            viewPosts model.rootPath posts


viewLoading : Html Msg
viewLoading =
    ul [ class "tree-view" ]
        [ li [] [ text "Loading ..." ] ]


viewPosts : RootPath -> List Post -> Html Msg
viewPosts rootPath posts =
    ul [ class "tree-view" ]
        (List.map (viewPost rootPath) posts)


viewPost : RootPath -> Post -> Html Msg
viewPost rootPath post =
    li []
        [ a [ href (linkToPost rootPath post.slug) ]
            [ text post.title ]
        ]


linkToPost : Maybe String -> String -> String
linkToPost rootPath slug =
    case rootPath of
        Just root ->
            absolute [ root, "posts", slug ] []

        Nothing ->
            absolute [ "posts", slug ] []


viewError : Http.Error -> Html Msg
viewError =
    text << buildErrorMessage


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message


main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
