module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Route exposing (Route)
import Page.Home as Home



-- MAIN


main : Program () Model Msg
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
    , page: Page
    , route : Route
    }


type Page
    = NotFoundPage
    | HomePage Home.Model
--  | PostsPage


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        model =
            { key = key
            , page = NotFoundPage
            , route = Route.parseUrl url
            }
    in
    initCurrentPage ( model, Cmd.none )


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
                    ( HomePage pageModel , Cmd.map HomePageMsg pageCmd )
    in
    ( {model | page = currentPage }
    , Cmd.batch [ existingCmds, wrappedPageCmds ]
    )


-- UPDATE


type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | HomePageMsg Home.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model.page ) of
     ( LinkClicked (Browser.Internal url), _ ) ->
        ( model, Nav.pushUrl model.key (Url.toString url) )

     ( LinkClicked (Browser.External href), _ ) ->
        ( model, Nav.load href )

     ( UrlChanged url, _ ) ->
        ( { model | route = Route.parseUrl url }
        , Cmd.none
        )
        |> initCurrentPage

     ( HomePageMsg subMsg, HomePage pageModel ) ->
        let
            ( updatedPageModel, updatedCmd ) =
                Home.update subMsg pageModel
        in
        ( { model | page = HomePage updatedPageModel }
        , Cmd.map HomePageMsg updatedCmd
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
    routeName = Route.toString model.route
  in
  { title = "Relm : " ++ routeName
  , body =
      [
        windowed (Route.toString model.route) (
        [ text <| "The current route is: " ++ routeName
        , ul [ class "tree-view"]
            [ viewLink "/"
            , viewLink "/bad-link"
            ]
        , pageSpecificView model
        ]
        )
      ]
  }


pageSpecificView : Model -> Html Msg
pageSpecificView model =
  case model.page of
    NotFoundPage -> notFoundView
    HomePage pageModel -> Home.view pageModel |> Html.map HomePageMsg


notFoundView : Html Msg
notFoundView =
    h3 [] [ text "The page you requested was not found!" ]


viewLink : String -> Html msg
viewLink path =
  li [] [ a [ href path ] [ text path ] ]


windowed : String -> List (Html msg) -> Html msg
windowed title content =
    div [ class "window", id "main-window"]
      [ div [ class "title-bar"]
        [ div [ class "title-bar-text"]
          [ text title ]
        , div [ class "title-bar-controls"]
          [ button [ attribute "aria-label" "Minimize" ] []
          , button [ attribute "aria-label" "Maximize" ] []
          , button [ attribute "aria-label" "Close" ] []
          ]
        ]
      , div [ class "window-body", id "elm"]
        content
      ]
