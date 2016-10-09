module Api exposing (..)

import Http exposing (Error)
import Json.Decode as Json exposing (..)
import Json.Encode exposing (encode)
import Task exposing (Task)
import Date exposing (Date)
import Model exposing (..)


getUser : Task Error User
getUser =
    Http.get decodeUser "/user"


decodeUser : Json.Decoder User
decodeUser =
    object3 User
        ("firstName" := string)
        ("lastName" := string)
        ("previousBalance" := float)


getEntries : Task Error (List DateEntries)
getEntries =
    Http.get decodeDayEntries "/entries"


decodeDayEntries : Json.Decoder (List DateEntries)
decodeDayEntries =
    list
        (object2 DateEntries
            ("date" := customDecoder string Date.fromString)
            ("entries" := list decodeEntry)
        )


decodeEntry : Json.Decoder Entry
decodeEntry =
    object2 Entry
        ("hours" := float)
        ("taskId" := int)


getNationalHolidays : Task Error (List Holiday)
getNationalHolidays =
    Http.get decodeHolidays "/holidays"


decodeHolidays : Json.Decoder (List Holiday)
decodeHolidays =
    list
        (object2 Holiday
            ("date" := customDecoder string Date.fromString)
            ("name" := string)
        )


getAbsenceTasks : Task Error (List HarvestTask)
getAbsenceTasks =
    Http.get decodeTasks "/ignored_tasks"


decodeTasks : Json.Decoder (List HarvestTask)
decodeTasks =
    list
        (object1 HarvestTask
            ("taskId" := int)
        )


setPreviousBalance : Float -> Task Error (List String)
setPreviousBalance balance =
    httpPost "/balance"
        (Http.string ("""{ "balance":""" ++ (toString balance) ++ """}"""))


httpPost : String -> Http.Body -> Task Error (List String)
httpPost url body =
    Http.send Http.defaultSettings
        { verb = "POST"
        , headers = [ ( "Content-type", "application/json" ) ]
        , url = url
        , body = body
        }
        |> Http.fromJson (Json.list Json.string)
