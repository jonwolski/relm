module Page.Index exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)


view model =
    div [ class "jumbotron" ]
        [ h1 [] [ text "Relm!" ]
        , p []
            [ text "Real World Application in Elm -> Relm"
            , text <|
                """
                This is the real world application + playground written in elm
                """
            ]
        ]


main =
    view "dummy model"
