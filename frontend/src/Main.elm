module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import GlobalFeed
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Home as Home
import Page.Post as Post
import Page.SignIn as SignIn
import Route exposing (Route)
import Url
import Url.Builder exposing (absolute)
import User exposing (User)



-- MAIN


main : Program (Maybe String) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , route : Route
    , globalFeed : GlobalFeed.Model
    , rootPath : Maybe String
    , user : Maybe User
    }


type Page
    = NotFoundPage
    | HomePage Home.Model
    | PostPage Post.Model
    | SignInPage SignIn.Model


init : Maybe String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init rootPath url key =
    let
        ( globalFeed, feedMsg ) =
            GlobalFeed.init rootPath

        wrappedFeedCmd =
            Cmd.map GlobalFeedMsg feedMsg

        model =
            { key = key
            , page = NotFoundPage
            , route = Route.parseUrl rootPath url
            , rootPath = rootPath
            , globalFeed = globalFeed
            , user = Nothing
            }
    in
    initCurrentPage ( model, wrappedFeedCmd )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, wrappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Home ->
                    let
                        ( pageModel, pageCmd ) =
                            Home.init model.key
                    in
                    ( HomePage pageModel, Cmd.map HomePageMsg pageCmd )

                Route.Post postId ->
                    let
                        ( pageModel, pageCmd ) =
                            Post.init postId model.key
                    in
                    ( PostPage pageModel, Cmd.map PostPageMsg pageCmd )

                Route.SignIn ->
                    let
                        ( pageModel, pageCmd ) =
                            SignIn.init model.key
                    in
                    ( SignInPage pageModel, Cmd.map SignInPageMsg pageCmd )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, wrappedPageCmds ]
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomePageMsg Home.Msg
    | PostPageMsg Post.Msg
    | SignInPageMsg SignIn.Msg
    | GlobalFeedMsg GlobalFeed.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked (Browser.Internal url), _ ) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        ( LinkClicked (Browser.External href), _ ) ->
            ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            ( { model | route = Route.parseUrl model.rootPath url }
            , Cmd.none
            )
                |> initCurrentPage

        ( GlobalFeedMsg subMsg, _ ) ->
            let
                ( updatedFeedModel, updatedCmd ) =
                    GlobalFeed.update subMsg model.globalFeed
            in
            ( { model | globalFeed = updatedFeedModel }
            , Cmd.map GlobalFeedMsg updatedCmd
            )

        ( HomePageMsg subMsg, HomePage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Home.update subMsg pageModel
            in
            ( { model | page = HomePage updatedPageModel }
            , Cmd.map HomePageMsg updatedCmd
            )

        ( PostPageMsg subMsg, PostPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Post.update subMsg pageModel
            in
            ( { model | page = PostPage updatedPageModel }
            , Cmd.map PostPageMsg updatedCmd
            )

        ( SignInPageMsg subMsg, SignInPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    SignIn.update subMsg pageModel

                user =
                    or model.user updatedPageModel.user
            in
            ( { model | page = SignInPage updatedPageModel, user = user }
            , Cmd.map SignInPageMsg updatedCmd
            )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        routeName =
            Route.toString model.route
    in
    { title = "Relm : " ++ routeName
    , body =
        [ windowed (Route.toString model.route)
            [ menuBar model
            , pageSpecificView model
            , Html.map GlobalFeedMsg (GlobalFeed.view model.globalFeed)
            ]
        ]
    }


menuBar : Model -> Html Msg
menuBar model =
    let
        maybeSignedInHtml =
            Maybe.map (displayUser model) model.user

        defaultHtml =
            [ viewLink model.rootPath "/login" "Sign in"
            , viewLink model.rootPath "/register" "Sign up"
            ]
    in
    ul [ class "menuBar" ]
        ([ viewLink model.rootPath "/" "Home" ]
            ++ Maybe.withDefault defaultHtml maybeSignedInHtml
        )


displayUser : Model -> User -> List (Html Msg)
displayUser model user =
    [ text user.username
    , viewLink model.rootPath "/logout" "Sign Out"
    ]


pageSpecificView : Model -> Html Msg
pageSpecificView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        HomePage pageModel ->
            Home.view pageModel |> Html.map HomePageMsg

        PostPage pageModel ->
            Post.view pageModel |> Html.map PostPageMsg

        SignInPage pageModel ->
            SignIn.view pageModel |> Html.map SignInPageMsg


notFoundView : Html Msg
notFoundView =
    h3 [] [ text "The page you requested was not found!" ]


viewLink : Maybe String -> String -> String -> Html msg
viewLink rootPath path text_ =
    let
        url =
            case rootPath of
                Just r ->
                    "/" ++ r ++ path

                Nothing ->
                    path
    in
    li [] [ a [ href url ] [ text text_ ] ]


windowed : String -> List (Html msg) -> Html msg
windowed title content =
    div [ class "window", id "main-window" ]
        [ div [ class "title-bar" ]
            [ div [ class "title-bar-text" ]
                [ text title ]
            , div [ class "title-bar-controls" ]
                [ button [ attribute "aria-label" "Minimize" ] []
                , button [ attribute "aria-label" "Maximize" ] []
                , button [ attribute "aria-label" "Close" ] []
                ]
            ]
        , div [ class "window-body", id "elm" ]
            content
        ]


or : Maybe a -> Maybe a -> Maybe a
or first second =
    case first of
        Just _ ->
            first

        _ ->
            second
