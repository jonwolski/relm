module Page.Home exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { navKey : Nav.Key
    }


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( { navKey = navKey }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [ class "logo-font" ]
            [ text "conduit" ]
        , p [] [ text "A place to share your knowledge." ]
        ]


type Msg
    = Default



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
