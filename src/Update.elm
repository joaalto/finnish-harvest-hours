module Update exposing (currentTime, getEntries, getHolidays, getSpecialTasks, getUser, handleError, noFx, setPreviousBalance, update, updatePreviousBalance)

import Api exposing (getEntries)
import Browser.Navigation exposing (load)
import Date exposing (Unit(..), add, today)
import DateUtils exposing (calculateHourBalance, hourBalanceOfCurrentMonth)
import Http exposing (Response)
import List exposing (isEmpty)
import Material
import Model exposing (..)
import String
import Task exposing (Task)
import Time


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        Login ->
            noFx model

        GetDayEntries ->
            ( model, getEntries )

        EntryList results ->
            case results of
                Ok entries ->
                    update UpdateHours { model | entries = entries }

                Err error ->
                    handleError model error

        FetchedUser result ->
            case result of
                Ok user ->
                    update UpdateHours
                        { model
                            | user = user
                            , previousBalanceString = String.fromFloat user.previousBalance
                            , previousBalance = user.previousBalance
                        }

                Err error ->
                    handleError model error

        FetchedHolidays result ->
            case result of
                Ok holidays ->
                    update UpdateHours { model | holidays = holidays }

                Err error ->
                    handleError model error

        UpdateHours ->
            if
                not
                    (isEmpty model.entries
                        || isEmpty model.holidays
                        || isEmpty model.specialTasks.ignore
                    )
            then
                let
                    newModel =
                        { model | loading = False }

                    hourBalance =
                        calculateHourBalance model
                in
                update UpdateHourBalanceOfCurrentMonth
                    { newModel
                        | totalHours = Just hourBalance.normalHours
                        , kikyHours = Just hourBalance.kikyHours
                    }

            else
                noFx model

        PreviousMonth ->
            update UpdateHourBalanceOfCurrentMonth { model | currentDate = add Months -1 model.currentDate }

        NextMonth ->
            update UpdateHourBalanceOfCurrentMonth { model | currentDate = add Months 1 model.currentDate }

        UpdateHourBalanceOfCurrentMonth ->
            noFx { model | hourBalanceOfCurrentMonth = Just (hourBalanceOfCurrentMonth model) }

        FetchedSpecialTaskList result ->
            case result of
                Ok tasks ->
                    update UpdateHours { model | specialTasks = tasks }

                Err error ->
                    handleError model error

        SetCurrentTime today ->
            noFx { model | currentDate = today, today = today }

        UpdatePreviousBalance balance ->
            updatePreviousBalance model balance

        SavePreviousBalance balance ->
            ( model, setPreviousBalance balance )

        PreviousBalanceSaved (Ok result) ->
            update UpdateHours model

        PreviousBalanceSaved (Err err) ->
            let
                log =
                    Debug.log "Error saving balance:" err
            in
            noFx model

        NavigateTo url ->
            ( model, load url )

        Mdc action_ ->
            Material.update Mdc action_ model

        Cancel ->
            noFx { model | showDialog = False }

        ShowDialog ->
            noFx { model | showDialog = True }



updatePreviousBalance : Model -> String -> ( Model, Cmd Msg )
updatePreviousBalance model balance =
    case String.toFloat balance of
        Nothing ->
            noFx { model | previousBalanceString = balance }

        Just value ->
            noFx { model | previousBalance = value, previousBalanceString = balance }


setPreviousBalance : Float -> Cmd Msg
setPreviousBalance balance =
    Http.send PreviousBalanceSaved (Api.setPreviousBalance balance)


currentTime : Cmd Msg
currentTime =
    Date.today |> Task.perform SetCurrentTime


noFx : Model -> ( Model, Cmd Msg )
noFx model =
    ( model, Cmd.none )


handleError : Model -> Http.Error -> ( Model, Cmd Msg )
handleError model error =
    case error of
        Http.BadStatus response ->
            let
                newModel =
                    { model | loading = False }
            in
            case response.status.code of
                401 ->
                    update (NavigateTo "/login") newModel

                _ ->
                    noFx { newModel | httpError = Err error }

        _ ->
            noFx { model | httpError = Err error }


getEntries : Cmd Msg
getEntries =
    Http.send EntryList Api.getEntries


getUser : Cmd Msg
getUser =
    Http.send FetchedUser Api.getUser


getHolidays : Cmd Msg
getHolidays =
    Http.send FetchedHolidays Api.getNationalHolidays


getSpecialTasks : Cmd Msg
getSpecialTasks =
    Http.send FetchedSpecialTaskList Api.getSpecialTasks
