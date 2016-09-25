module Update exposing (..)

import Material
import List exposing (isEmpty)
import Task exposing (Task)
import Http
import Model exposing (..)
import Api exposing (getEntries)
import DateUtils exposing (enteredHoursVsTotal)
import Date.Extra.Duration as Duration
import Date exposing (fromTime)
import Basics.Extra exposing (never)
import Time


type Msg
    = Login
    | GetDayEntries
    | EntryList (Result Http.Error (List DateEntries))
    | FetchedUser (Result Http.Error (User))
    | FetchedHolidays (Result Http.Error (List Holiday))
    | UpdateHours
    | PreviousMonth
    | NextMonth
    | FetchedAbsenceTaskList (Result Http.Error (List HarvestTask))
    | SetCurrentTime (Time.Time)
    | UpdatePreviousBalance String
    | SavePreviousBalance String
    | PreviousBalanceSaved (Result Http.Error (List String))
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
                    noFx { model | user = user }

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
                        || isEmpty model.absenceTasks
                    )
            then
                let
                    newModel =
                        { model | loading = False }
                in
                    noFx { newModel | totalHours = enteredHoursVsTotal model }
            else
                noFx model

        PreviousMonth ->
            noFx { model | currentDate = Duration.add Duration.Month -1 model.currentDate }

        NextMonth ->
            noFx { model | currentDate = Duration.add Duration.Month 1 model.currentDate }

        FetchedAbsenceTaskList result ->
            case result of
                Ok tasks ->
                    update UpdateHours { model | absenceTasks = tasks }

                Err error ->
                    handleError model error

        SetCurrentTime currentTime ->
            noFx { model | currentDate = Date.fromTime currentTime, today = Date.fromTime currentTime }

        UpdatePreviousBalance balance ->
            noFx { model | previousBalance = balance }

        SavePreviousBalance balance ->
            ( model, setPreviousBalance balance )

        PreviousBalanceSaved result ->
            noFx model

        Mdl action' ->
            Material.update action' model


setPreviousBalance : String -> Cmd Msg
setPreviousBalance balance =
    getResult (Api.setPreviousBalance balance) PreviousBalanceSaved


currentTime : Cmd Msg
currentTime =
    Task.perform never SetCurrentTime Time.now


noFx : Model -> ( Model, Cmd Msg )
noFx model =
    ( model, Cmd.none )


handleError : Model -> Http.Error -> ( Model, Cmd Msg )
handleError model error =
    noFx { model | httpError = Err error }


getResult : Task Http.Error a -> (Result Http.Error a -> Msg) -> Cmd Msg
getResult httpGet action =
    httpGet
        |> Task.toResult
        |> Task.perform never action


getEntries : Cmd Msg
getEntries =
    getResult Api.getEntries EntryList


getUser : Cmd Msg
getUser =
    getResult Api.getUser FetchedUser


getHolidays : Cmd Msg
getHolidays =
    getResult Api.getNationalHolidays FetchedHolidays


getAbsenceTasks : Cmd Msg
getAbsenceTasks =
    getResult Api.getAbsenceTasks FetchedAbsenceTaskList
