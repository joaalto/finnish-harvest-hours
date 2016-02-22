module Model (..) where

import Date exposing (Date)
import Http


type alias Model =
  { httpError : Result Http.Error ()
  , currentDate : Date
  , entries : List Entry
  , hours : Float
  }


type alias Entry =
  { date : Date
  , hours : Float
  }
