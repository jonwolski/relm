module SignUp exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }


-- USER

type alias SignUp =
  { email : String
  , username : String
  , password : String
  , passwordAgain : String
  , submitted : Bool
  }

init : SignUp
init = SignUp "" "" "" "" False


-- UPDATE
type Msg
  = Email String
  | Username String
  | Password String
  | PasswordAgain String
  | Validate


update : Msg -> SignUp -> SignUp
update msg model =
  case msg of
    Email email ->
      { model | email = email }

    Username username ->
      { model | username = username }

    Password password ->
      { model | password = password }

    PasswordAgain password ->
      { model | passwordAgain = password }

    Validate ->
      { model | submitted = True }


signUp : SignUp -> Cmd Msg
signUp model =
  Http.post
    { url = "http://localhost:6001/"
    , body = Http.emptyBody
    , expect = Http.expectJson
    }


-- VIEW
view : SignUp -> Html Msg
view model =
    div []
    [ viewInput "text" "Username" model.username Username
    , viewInput "text" "Email" model.email Email
    , viewInput "password" "Password" model.password Password
    , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
    , viewSubmit "Sign Up" model
    , viewValidation model.password model.passwordAgain
    , viewInformation model
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [type_ t, placeholder p, value v, onInput toMsg] []


viewSubmit : String -> SignUp -> Html Msg
viewSubmit title model =
  button [ onClick Validate ] [text title]


viewValidation : String -> String -> Html msg
viewValidation password passwordAgain =
  if password == passwordAgain then
    div [ style "color" " green"] [ text "OK"]
  else
    div [ style "color" "red"] [ text "passwords do not match"]

viewInformation : SignUp -> Html msg
viewInformation model =
  if model.submitted == True then
    div [ style "color" "blue" ] [text model.email, text model.username]
  else
    div [style "color" "red"] [text "Please Sign Up :)"]
