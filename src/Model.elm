module Model exposing (DateEntries, DateHours, Entry, HarvestTask, Holiday, Hours, Model, Msg(..), SpecialTasks, User)

import Browser
import Date exposing (Date, Month)
import Http
import Material


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
    | SetCurrentTime Date
    | UpdatePreviousBalance String
    | SavePreviousBalance Float
    | PreviousBalanceSaved (Result Http.Error String)
    | NavigateTo String
    | Mdc (Material.Msg Msg)
    | ShowDialog
    | Cancel


type alias Model =
    { httpError : Result Http.Error ()
    , loading : Bool
    , today : Date
    , currentDate : Date
    , entries : List DateEntries
    , totalHours : Maybe Float
    , kikyHours : Maybe Float
    , hourBalanceOfCurrentMonth : Maybe Float
    , user : User
    , holidays : List Holiday
    , specialTasks : SpecialTasks
    , previousBalanceString : String
    , previousBalance : Float
    , mdc : Material.Model Msg
    , showDialog : Bool
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


type alias Hours a =
    { a
        | normalHours : Float
        , kikyHours : Float
    }


type alias DateHours =
    Hours { date : Date }
