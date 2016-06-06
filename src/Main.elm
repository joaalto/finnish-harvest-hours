module Main exposing (..)

import Model exposing (..)
import Update exposing (Msg, update)
import View exposing (view)
import Html.App as Html
import Ports exposing (currentTime)
import Date.Extra.Create exposing (dateFromFields)
import Date exposing (..)

main : Program Never
main =
    Html.program
      { init = init
      , update = update
      , view = view
      , subscriptions = subscriptions
      }

subscriptions : Model -> Sub Msg
subscriptions model =
  currentTime Update.GetCurrentTime

init : ( Model, Cmd Msg )
init =
  ( initialModel
  , Cmd.batch
      [ Update.getUser
      , Update.getEntries
      , Update.getHolidays
      , Update.getAbsenceTasks
      ]
  )


initialModel : Model
initialModel =
    { httpError = Ok ()
    , loading = True
    , today = Date.Extra.Create.dateFromFields 2016 Date.Jan 1 1 1 1 1
    , currentDate = Date.Extra.Create.dateFromFields 2016 Date.Jan 1 1 1 1 1
    , entries = []
    , totalHours = 0
    , user = { firstName = "", lastName = "" }
    , holidays = []
    , absenceTasks = []
    }
