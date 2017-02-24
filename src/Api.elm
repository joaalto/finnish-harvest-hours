module Api exposing (..)

import Http exposing (Request, Body, Error, jsonBody)
import Json.Decode as Json exposing (..)
import Json.Encode as Encode
import Json.Decode.Extra exposing (date)
import Model exposing (..)


getUser : Request User
getUser =
    Http.get "/user" decodeUser


decodeUser : Json.Decoder User
decodeUser =
    map3 User
        (field "firstName" string)
        (field "lastName" string)
        (field "previousBalance" float)


getEntries : Request (List DateEntries)
getEntries =
    Http.get "/entries" decodeDayEntries


decodeDayEntries : Json.Decoder (List DateEntries)
decodeDayEntries =
    list
        (map2 DateEntries
            (field "date" date)
            (field "entries" (list decodeEntry))
        )


decodeEntry : Json.Decoder Entry
decodeEntry =
    map2 Entry
        (field "hours" float)
        (field "taskId" int)


getNationalHolidays : Request (List Holiday)
getNationalHolidays =
    Http.get "/holidays" decodeHolidays


decodeHolidays : Json.Decoder (List Holiday)
decodeHolidays =
    list
        (map2 Holiday
            (field "date" date)
            (field "name" string)
        )


getSpecialTasks : Request SpecialTasks
getSpecialTasks =
    Http.get "/special_tasks" decodeTasks


decodeTasks : Json.Decoder SpecialTasks
decodeTasks =
    map2 SpecialTasks
        (field "ignore"
            (list
                (map HarvestTask
                    (field "taskId" int)
                )
            )
        )
        (field "kiky"
            (list
                (map HarvestTask
                    (field "taskId" int)
                )
            )
        )


setPreviousBalance : Float -> Request (List String)
setPreviousBalance balance =
    httpPost "/balance"
        (jsonBody
            (Encode.object
                [ ( "balance", Encode.float balance )
                ]
            )
        )



--        (jsonBody ("""{ "balance":""" ++ (toString balance) ++ """}"""))
--httpPost : String -> Http.Body -> Task Error (List String)


httpPost : String -> Body -> Request (List String)
httpPost url body =
    --    Http.send
    (Http.post url
        body
        (Json.list Json.string)
    )
