module Update exposing (..)

import Material
import String
import List exposing (isEmpty)
import Task exposing (Task)
import Http exposing (Response)
import Navigation exposing (load)
import Model exposing (..)
import Api exposing (getEntries)
import DateUtils exposing (calculateHourBalance, hourBalanceOfCurrentMonth)
import Date.Extra.Duration as Duration
import Date exposing (fromTime)


--import Basics.Extra exposing (never)

import Time


type Msg
    = Login
    | GetDayEntries
    | EntryList (Result Http.Error (List DateEntries))
    | FetchedUser (Result Http.Error User)
    | FetchedHolidays (Result Http.Error (List Holiday))
    | UpdateHours
    | PreviousMonth
    | NextMonth
    | UpdateHourBalanceOfCurrentMonth
    | FetchedSpecialTaskList (Result Http.Error SpecialTasks)
    | SetCurrentTime Time.Time
    | UpdatePreviousBalance String
    | SavePreviousBalance Float
    | PreviousBalanceSaved (Result Http.Error (List String))
    | NavigateTo String
    | Mdl (Material.Msg Msg)


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
                            , previousBalanceString = toString user.previousBalance
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
                        (Debug.log "hours" (calculateHourBalance model))
                in
                    update UpdateHourBalanceOfCurrentMonth
                        { newModel
                            | totalHours = Just (hourBalance.normalHours)
                            , kikyHours = Just (hourBalance.kikyHours)
                        }
            else
                noFx model

        PreviousMonth ->
            update UpdateHourBalanceOfCurrentMonth { model | currentDate = Duration.add Duration.Month -1 model.currentDate }

        NextMonth ->
            update UpdateHourBalanceOfCurrentMonth { model | currentDate = Duration.add Duration.Month 1 model.currentDate }

        UpdateHourBalanceOfCurrentMonth ->
            noFx { model | hourBalanceOfCurrentMonth = Just (hourBalanceOfCurrentMonth model) }

        FetchedSpecialTaskList result ->
            case result of
                Ok tasks ->
                    update UpdateHours { model | specialTasks = tasks }

                Err error ->
                    handleError model error

        SetCurrentTime currentTime ->
            noFx { model | currentDate = Date.fromTime currentTime, today = Date.fromTime currentTime }

        UpdatePreviousBalance balance ->
            updatePreviousBalance model balance

        SavePreviousBalance balance ->
            ( model, setPreviousBalance balance )

        PreviousBalanceSaved (Ok result) ->
            update UpdateHours model

        PreviousBalanceSaved (Err err) ->
            ( model, Cmd.none )

        NavigateTo url ->
            ( model, Navigation.load url )

        Mdl action_ ->
            Material.update Mdl action_ model


updatePreviousBalance : Model -> String -> ( Model, Cmd Msg )
updatePreviousBalance model balance =
    case String.toFloat balance of
        Err error ->
            noFx { model | previousBalanceString = balance }

        Ok value ->
            noFx { model | previousBalance = value, previousBalanceString = balance }


setPreviousBalance : Float -> Cmd Msg
setPreviousBalance balance =
    Http.send PreviousBalanceSaved (Api.setPreviousBalance balance)


currentTime : Cmd Msg
currentTime =
    Task.perform SetCurrentTime Time.now


noFx : Model -> ( Model, Cmd Msg )
noFx model =
    ( model, Cmd.none )


handleError : Model -> Http.Error -> ( Model, Cmd Msg )
handleError model error =
    case error of
        Http.BadStatus response ->
            let
                ll =
                    (Debug.log ">>> status" response.status)

                newModel =
                    { model | loading = False }
            in
                case response.status.code of
                    401 ->
                        --                        ( newModel, (Cmd.batch [ (newUrl "/login"), (forward 1) ]) )
                        update (NavigateTo "/login") newModel

                    --                        ( model, (Task.perform never NavigateTo "/login") )
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
