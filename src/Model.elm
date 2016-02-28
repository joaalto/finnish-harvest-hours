module Model (..) where

import Date exposing (Date)
import Http


type alias Model =
  { httpError : Result Http.Error ()
  , currentDate : Date
  , entries : List DateEntries
  , totalHours : Float
  }


type alias DateEntries =
  { date : Date
  , entries : List Entry
  }


type alias Entry =
  { hours : Float
  , taskId : Int
  }
