module Init exposing (init, initialModel)
import Model exposing (..)
import Update exposing (Msg, update)
import Date exposing (..)
import Material

init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.batch
        [ Update.currentTime
        , Update.getUser
        , Update.getEntries
        , Update.getHolidays
        , Update.getSpecialTasks
        , Update.initDatePicker
        ]
    )


initialModel : Model
initialModel =
        { httpError = Ok ()
        , loading = True
        , today = Date.fromTime 0
        , currentDate = Date.fromTime 0
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
        , startDate = Nothing
        , datePicker = Nothing
        , mdl = Material.model
        }
