module Update (..) where

import Effects exposing (Effects)
import Task exposing (Task)
import Http
import Model exposing (..)
import Api exposing (getEntries)
import DateUtils exposing (enteredHoursVsTotal)


type Action
  = Login
  | GetDayEntries
  | EntryList (Result Http.Error (List DateEntries))
  | FetchedUser (Result Http.Error (User))
  | FetchedHolidays (Result Http.Error (List Holiday))


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Login ->
      noFx model

    GetDayEntries ->
      ( model, getEntries )

    EntryList results ->
      case results of
        Ok entries ->
          let
            newModel =
              { model | entries = entries }
          in
            noFx { model | totalHours = enteredHoursVsTotal newModel }

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
          noFx { model | holidays = holidays }

        Err error ->
          handleError model error


noFx : Model -> ( Model, Effects Action )
noFx model =
  ( model, Effects.none )


handleError : Model -> Http.Error -> ( Model, Effects Action )
handleError model error =
  noFx { model | httpError = Err error }


getEntries : Effects Action
getEntries =
  Api.getEntries
    |> Task.toResult
    |> Task.map EntryList
    |> Effects.task


getUser : Effects Action
getUser =
  Api.getUser
    |> Task.toResult
    |> Task.map FetchedUser
    |> Effects.task


getHolidays : Effects Action
getHolidays =
  Api.getNationalHolidays
    |> Task.toResult
    |> Task.map FetchedHolidays
    |> Effects.task
