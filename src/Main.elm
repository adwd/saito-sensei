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


port requestPushNotification : () -> Cmd msg


port pushNotificationPermissionChange : (String -> msg) -> Sub msg



---- MODEL ----


type alias Model =
    { isSignedIn : Bool
    , signInResult : String
    , pushPermission : String
    }


type alias Flags =
    { pushPermission : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { isSignedIn = False, signInResult = "", pushPermission = flags.pushPermission }, Cmd.none )



---- UPDATE ----


type Msg
    = SignIn
    | SignedIn Bool
    | SignInSuccess String
    | SignInFailure String
    | RequestPushNotification
    | PushNotificationPermissionChange String


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

        RequestPushNotification ->
            ( model, requestPushNotification () )

        PushNotificationPermissionChange permission ->
            ( { model | pushPermission = permission }, Cmd.none )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Element.layout [] (senseiApp model)


senseiApp : Model -> Element Msg
senseiApp model =
    column [ width fill ]
        [ senseiHeader
        , senseiContent model
        ]


senseiHeader : Element Msg
senseiHeader =
    row [ width fill, padding 20 ]
        [ el [ centerX ] (text "sensei")
        ]


senseiContent : Model -> Element Msg
senseiContent model =
    column [ width fill, padding 20 ]
        [ image [ width (px 128), padding 20 ] { src = "/logo.svg", description = "logo" }
        , el [] (text "Saito Sensei")
        , el [] (text model.pushPermission)
        , case model.pushPermission of
            "granted" ->
                el [] (text "push permission granted")

            "denied" ->
                none

            _ ->
                Input.button [] { label = text "receive push notification", onPress = Just RequestPushNotification }
        , Input.button [] { label = text "sign in", onPress = Just SignIn }
        , if model.isSignedIn then
            paragraph []
                [ text "signed in"
                , text model.signInResult
                ]

          else
            paragraph [] [ text "not signed in" ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ signedIn SignedIn, signInFailure SignInFailure, signInSuccess SignInSuccess, pushNotificationPermissionChange PushNotificationPermissionChange ]



---- PROGRAM ----


main : Program Flags Model Msg
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
