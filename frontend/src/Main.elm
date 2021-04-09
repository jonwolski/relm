module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url



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
  , url : Url.Url
  }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url, Cmd.none )



-- UPDATE


type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

    UrlChanged url ->
      ( { model | url = url }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
  { title = "Relm Alright Cool"
  , body =
      [
        windowed (Url.toString model.url) (
        [ text "The current URL is: "
        , ul [ class "tree-view"]
            [ viewLink "/home"
            ]
        ]
        )
      ]
  }


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
