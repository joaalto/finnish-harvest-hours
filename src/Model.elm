module Model exposing (..)

import Date exposing (Date, Month)
import Http


type alias Model =
  { httpError : Result Http.Error ()
  , loading : Bool
  , today : Date
  , currentDate : Date
  , entries : List DateEntries
  , totalHours : Float
  , user : User
  , holidays : List Holiday
  , absenceTasks : List HarvestTask
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


type alias HarvestTask =
  { id : Int
  , name : String
  }
