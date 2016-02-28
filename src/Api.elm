module Api (..) where

import Http exposing (Error)
import Json.Decode as Json exposing (..)
import Task exposing (Task)
import Date exposing (Date)
import Model exposing (..)


getUser : Task Error User
getUser =
  Http.get decodeUser "/user"


decodeUser : Json.Decoder User
decodeUser =
  object2
    User
    ("firstName" := string)
    ("lastName" := string)


getEntries : Task Error (List DateEntries)
getEntries =
  Http.get decodeDayEntries "/entries"


decodeDayEntries : Json.Decoder (List DateEntries)
decodeDayEntries =
  list
    (object2
      DateEntries
      ("date" := customDecoder string Date.fromString)
      ("entries" := list decodeEntry)
    )


decodeEntry : Json.Decoder Entry
decodeEntry =
  object2
    Entry
    ("hours" := float)
    ("taskId" := int)
