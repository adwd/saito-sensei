// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        signIn: {
          subscribe(callback: (data: null) => void): void
        }
        signedIn: {
          send(data: { photoURL: string | null }): void
        }
        signInFailed: {
          send(data: string): void
        }
        requestPushNotification: {
          subscribe(callback: (data: null) => void): void
        }
        pushNotificationPermissionChange: {
          send(data: string): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: { pushPermission: string };
    }): Elm.Main.App;
  }
}