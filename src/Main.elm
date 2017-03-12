module Main exposing (..)

import Init exposing (init, initialModel)
import Model exposing (..)
import Update exposing (Msg, update)
import View exposing (view)
import Html


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (always Sub.none)
        }


