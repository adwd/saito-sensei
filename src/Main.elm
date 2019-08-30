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
import Debug
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html



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


view : Model -> Html.Html Msg
view model =
    Element.layout [] (senseiApp model)


senseiApp : Model -> Element Msg
senseiApp model =
    column [ width fill, Element.explain Debug.todo ]
        [ senseiHeader
        , senseiContent model
        ]


senseiHeader : Element Msg
senseiHeader =
    row [ width fill, padding 20 ]
        [ el [ centerX ] (text "header")
        ]


senseiContent : Model -> Element Msg
senseiContent model =
    column [ width fill, padding 20 ]
        [ image [ width (px 128), padding 20 ] { src = "/logo.svg", description = "logo" }
        , el [] (text "Saito Sensei")
        , Input.button [] { label = text "sign in", onPress = Just SignIn }
        , if model.isSignedIn then
            paragraph []
                [ text model.signInResult
                ]

          else
            none
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
