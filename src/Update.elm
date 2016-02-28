module Update (..) where

import Effects exposing (Effects)
import Task exposing (Task)
import Http
import Model exposing (..)
import Api exposing (getEntries)


type Action
  = Login
  | GetDayEntries
  | EntryList (Result Http.Error (List DateEntries))


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
          noFx { model | entries = entries }

        Err error ->
          noFx { model | httpError = Err error }


noFx : Model -> ( Model, Effects Action )
noFx model =
  ( model, Effects.none )


getEntries : Effects Action
getEntries =
  Api.getEntries
    |> Task.toResult
    |> Task.map EntryList
    |> Effects.task
