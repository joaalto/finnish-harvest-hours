module Main exposing (..)

import Model exposing (..)
import Update exposing (Msg, update)
import View exposing (view)
import Html.App as Html
import Date exposing (..)


main : Program Never
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (always Sub.none)
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.batch
        [ Update.currentTime
        , Update.getUser
        , Update.getEntries
        , Update.getHolidays
        , Update.getAbsenceTasks
        ]
    )


initialModel : Model
initialModel =
    { httpError = Ok ()
    , loading = True
    , today = Date.fromTime 0
    , currentDate = Date.fromTime 0
    , entries = []
    , totalHours = 0
    , user = { firstName = "", lastName = "" }
    , holidays = []
    , absenceTasks = []
    }
