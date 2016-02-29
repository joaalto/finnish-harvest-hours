module Model (..) where

import Date exposing (Date)
import Http


type alias Model =
  { httpError : Result Http.Error ()
  , currentDate : Date
  , entries : List DateEntries
  , totalHours : Float
  , user : User
  , holidays : List Holiday
  }


type alias User =
  { firstName : String
  , lastName : String
  }


type alias DateEntries =
  { date : Date
  , entries : List Entry
  }


type alias Entry =
  { hours : Float
  , taskId : Int
  }


type alias Holiday =
  { date : Date
  , name : String
  }
