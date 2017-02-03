module Model exposing (..)

import Material
import Date exposing (Date, Month)
import Http


type alias Model =
    { httpError : Result Http.Error ()
    , loading : Bool
    , today : Date
    , currentDate : Date
    , entries : List DateEntries
    , totalHours : Maybe Float
    , hourBalanceOfCurrentMonth : Maybe Float
    , user : User
    , holidays : List Holiday
    , specialTasks : SpecialTasks
    , previousBalanceString : String
    , previousBalance : Float
    , mdl : Material.Model
    }


type alias User =
    { firstName : String
    , lastName : String
    , previousBalance : Float
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
    { id : Int }


type alias SpecialTasks =
    { ignore : List HarvestTask
    , kiky : List HarvestTask
    }


type alias DateHours =
    { date : Date
    , normalHours : NormalHours
    , kikyHours : KikyHours
    }


type NormalHours
    = NormalHours Float


type KikyHours
    = KikyHours Float
