module Init exposing (init, initialModel)

import Model exposing (..)
import Update exposing (Msg(ToDatePicker), update)
import Date exposing (..)
import Material
import DatePicker exposing (defaultSettings)


init : ( Model, Cmd Msg )
init =
    let
        ( model, datePickerMsg ) =
            initialModel
    in
        ( model
        , Cmd.batch
            [ Update.currentTime
            , Update.getUser
            , Update.getEntries
            , Update.getHolidays
            , Update.getSpecialTasks
            , datePickerMsg
            ]
        )


initialModel : ( Model, Cmd Msg )
initialModel =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init defaultSettings

        model =
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
            , datePicker = datePicker
            , mdl = Material.model
            }
    in
        ( model, Cmd.map ToDatePicker datePickerFx )
