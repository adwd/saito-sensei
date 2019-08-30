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
          send(data: boolean): void
        }
        signInSuccess: {
          send(data: string): void
        }
        signInFailure: {
          send(data: string): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: null;
    }): Elm.Main.App;
  }
}