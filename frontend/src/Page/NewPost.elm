module Page.NewPost exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser.Navigation as Nav
import Html exposing (..)


type alias Model =
    { navKey : Nav.Key
    }


type alias NewPost =
    { title : String
    , body : String
    , tagList : List String
    , description : String
    }


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( initialModel navKey, Cmd.none )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    }



-- VIEW


view : Model -> Html Msg
view model = text "Hello NewPost"
{-
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

-}

viewPost : NewPost -> Html Msg
viewPost post =
    div [ class "container" ]
        [ h1 [ class "logo-font" ]
            [ text post.title ]
        , cite [] [ text post.author.username ]
        , div [ class "publishedDate" ]
            [ text "Last updated at"
            ]
        , div [] [ text post.body ]
        ]


type Msg
    = GetPost String



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
