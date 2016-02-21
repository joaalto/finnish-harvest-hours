module Model (..) where

import Date exposing (Date)
import Http


type alias Model =
  { httpError : Result Http.Error ()
  , entries : List Entry
  , hours : Int
  }


type alias Entry =
  { date : Date
  , hours : Int
  }
