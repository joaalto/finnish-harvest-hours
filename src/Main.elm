module Main exposing (init, initialModel, main)

import Date exposing (fromPosix)
import Time exposing (millisToPosix, utc)
import Browser
import Material
import Model exposing (..)
import Update exposing (update)
import View exposing (view)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : () ->  ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.batch
        [ Update.currentTime
        , Update.getUser
        , Update.getEntries
        , Update.getHolidays
        , Update.getSpecialTasks
        ]
    )


initialModel : Model
initialModel =
    { httpError = Ok ()
    , loading = True
    , today = fromPosix utc (millisToPosix 0)
    , currentDate = fromPosix utc (millisToPosix 0)
    , entries = []
    , totalHours = Nothing
    , kikyHours = Nothing
    , hourBalanceOfCurrentMonth = Nothing
    , user = { firstName = "", lastName = "", previousBalance = 0 }
    , holidays = []
    , specialTasks =
        { ignore = []
        , kiky = []
        }
    , previousBalanceString = ""
    , previousBalance = 0
    , mdc = Material.defaultModel
    , showDialog = False
    }
