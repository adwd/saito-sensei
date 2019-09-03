port module Main exposing
    ( Model
    , Msg(..)
    , init
    , main
    , signedIn
    , update
    , view
    )

import Browser
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



---- PORTS ----


port signIn : () -> Cmd msg


port signedIn : (User -> msg) -> Sub msg


port requestPushNotification : () -> Cmd msg


port pushNotificationPermissionChange : (String -> msg) -> Sub msg



---- MODEL ----


type alias User =
    { photoURL : Maybe String }


type SignInUser
    = NotSignIn
    | SignInUser User


type alias Model =
    { signInUser : SignInUser
    , pushPermission : String
    }


type alias Flags =
    { pushPermission : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { signInUser = NotSignIn
      , pushPermission = flags.pushPermission
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = SignIn
    | SignedIn User
    | RequestPushNotification
    | PushNotificationPermissionChange String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignIn ->
            ( model, signIn () )

        SignedIn user ->
            ( { model | signInUser = SignInUser user }, Cmd.none )

        RequestPushNotification ->
            ( model, requestPushNotification () )

        PushNotificationPermissionChange permission ->
            ( { model | pushPermission = permission }, Cmd.none )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    div
        [ class "d-flex flex-column"
        , style "min-height" "100vh"
        ]
        [ senseiHeader model
        , senseiApp model
        ]


senseiHeader : Model -> Html.Html Msg
senseiHeader model =
    div
        [ style "top" "0px"
        , style "z-index" "1"
        , style "position" "sticky"
        ]
        [ div [ class "d-flex flex-justify-between flex-items-center bg-gray-dark text-white " ]
            [ div [ class "p-3 f1" ] [ text "saito-sensei" ]
            , div [] []
            , div [ class "p-1 f2" ]
                [ case model.signInUser of
                    NotSignIn ->
                        button
                            [ class "btn-link"
                            , type_ "button"
                            , onClick SignIn
                            ]
                            [ text "sign in" ]

                    SignInUser user ->
                        case user.photoURL of
                            Just url ->
                                img
                                    [ class "avatar"
                                    , alt "todo"
                                    , src url
                                    , width 48
                                    , height 48
                                    ]
                                    []

                            Nothing ->
                                div [] []
                ]
            ]
        ]


senseiApp : Model -> Html.Html Msg
senseiApp model =
    div []
        [ case model.pushPermission of
            "granted" ->
                text "push permission granted"

            "denied" ->
                text "push permission denied"

            _ ->
                button
                    [ type_ "button"
                    , onClick RequestPushNotification
                    ]
                    [ text "recieive push notification" ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ signedIn SignedIn, pushNotificationPermissionChange PushNotificationPermissionChange ]



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
