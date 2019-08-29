port module Main exposing
    ( Model
    , Msg(..)
    , init
    , main
    , signInFailure
    , signInSuccess
    , signedIn
    , update
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



---- PORTS ----


port signIn : () -> Cmd msg


port signedIn : (Bool -> msg) -> Sub msg


port signInSuccess : (String -> msg) -> Sub msg


port signInFailure : (String -> msg) -> Sub msg



---- MODEL ----


type alias Model =
    { isSignedIn : Bool
    , signInResult : String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { isSignedIn = False, signInResult = "" }, Cmd.none )



---- UPDATE ----


type Msg
    = SignIn
    | SignedIn Bool
    | SignInSuccess String
    | SignInFailure String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignIn ->
            ( model, signIn () )

        SignedIn isSignedIn ->
            ( { model | isSignedIn = isSignedIn }, Cmd.none )

        SignInSuccess message ->
            ( { model | signInResult = message }, Cmd.none )

        SignInFailure message ->
            ( { model | signInResult = message }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view { isSignedIn, signInResult } =
    div [ class "container" ]
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Saito Sensei is working!" ]
        , button [ onClick SignIn ] [ text "Google サインイン" ]
        , if isSignedIn then
            text signInResult

          else
            text ""
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ signedIn SignedIn, signInFailure SignInFailure, signInSuccess SignInSuccess ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Saito Sensei"
                , body = [ view m ]
                }
        , subscriptions = subscriptions
        }
