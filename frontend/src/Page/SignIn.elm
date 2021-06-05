module Page.SignIn exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Error
import Html exposing (..)
import Html.Attributes exposing (class, classList, datetime, placeholder, property, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Iso8601 exposing (fromTime)
import Json.Decode as Decode exposing (Decoder, Error(..), bool, field, int, list, nullable, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import RemoteData exposing (RemoteData, WebData)
import Route
import Time
import Url
import Url.Builder exposing (absolute)
import Url.Parser exposing (Parser, custom)
import User exposing (User)


type Msg
    = SignIn
    | SetUsername String
    | SetPassword String
    | SignInResponded (Result Http.Error SignInResponse)


type alias Model =
    { navKey : Nav.Key
    , username : String
    , password : String
    , signInResponse : WebData SignInResponse
    , saveError : Maybe String
    , user : Maybe User
    }


type alias SignInResponse =
    { user : User
    }


type alias User =
    { email : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    , token : String
    }


signInResponseDecoder : Decoder SignInResponse
signInResponseDecoder =
    Decode.succeed SignInResponse
        |> required "user" User.decoder


signInRequestEncoder : Model -> Encode.Value
signInRequestEncoder model =
    Encode.object
        [ ( "user"
          , Encode.object
                [ ( "email", Encode.string model.username )
                , ( "password", Encode.string model.password )
                ]
          )
        ]


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( { navKey = navKey

      {--Maybe/Nothing would seem to be useful, but we will have to handle
              the case of an empty string anyway. We might as well init to ""
              and avoid the complexity of unwrapping Maybes.
          --}
      , username = ""
      , password = ""
      , signInResponse = RemoteData.NotAsked
      , saveError = Nothing
      , user = Nothing
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewErrorMessage model.saveError
        , viewForm model
        ]


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage error =
    case error of
        Nothing ->
            text ""

        Just errorMsg ->
            p [ class "error" ] [ text errorMsg ]


viewForm : Model -> Html Msg
viewForm model =
    form [ onSubmit SignIn ]
        [ fieldset []
            [ legend [] [ text "Sign in form" ]
            , label []
                [ text "User name"
                , input [ type_ "text", onInput SetUsername ] []
                ]
            , label []
                [ text "Password"
                , input [ type_ "password", onInput SetPassword ] []
                ]
            ]
        , button [ type_ "submit" ] [ text "Sign in" ]
        ]



{--
viewWrapper : Html Msg -> Html Msg
viewWrapper contents =
    div [ class "auth-page" ] [
        div ( classes "container page") [
            div [ class "row" ] [
                div ( classes "col-md-6 offset-md-3 col-xs-12") [
                    contents
                ]
            ]
        ]
    ]

classes : String -> List (Attribute msg)
classes = String.split " " >> List.map class

--}
{--

<div class="auth-page">
  <div class="container page">
    <div class="row">
      <div class="col-md-6 offset-md-3 col-xs-12">
        <h1 class="text-xs-center">Sign up</h1>
        <p class="text-xs-center">
          <a href="">Have an account?</a>
        </p>

        <ul class="error-messages">
          <li>That email is already taken</li>
        </ul>

        <form>
          <fieldset class="form-group">
            <input class="form-control form-control-lg" type="text" placeholder="Your Name">
          </fieldset>
          <fieldset class="form-group">
            <input class="form-control form-control-lg" type="text" placeholder="Email">
          </fieldset>
          <fieldset class="form-group">
            <input class="form-control form-control-lg" type="password" placeholder="Password">
          </fieldset>
          <button class="btn btn-lg btn-primary pull-xs-right">
            Sign up
          </button>
        </form>
      </div>

    </div>
  </div>
</div>

--}
-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        SignIn ->
            ( model, signIn model )

        SignInResponded (Ok signInResponse) ->
            let
                wrappedSignInResponse =
                    RemoteData.succeed signInResponse
            in
            ( { model
                | signInResponse = wrappedSignInResponse
                , saveError = Nothing
                , user = Just signInResponse.user
              }
            , Route.pushUrl Route.Home model.navKey
            )

        SignInResponded (Err error) ->
            ( { model
                | saveError = Just <| buildErrorMessage error
                , user = Nothing
              }
            , Cmd.none
            )


signIn : Model -> Cmd Msg
signIn model =
    Http.post
        { url = "https://conduit.productionready.io/api/users/login"
        , body = Http.jsonBody (signInRequestEncoder model)
        , expect = Http.expectJson SignInResponded signInResponseDecoder
        }



{--Override the generic error handling, because the API will respond 422 on failed log-in
--}


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadStatus 422 ->
            "E-mail or password is invalid"

        _ ->
            Error.buildErrorMessage httpError
