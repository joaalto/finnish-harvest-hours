module Api (..) where

import Http exposing (Error)
import Json.Decode as Json exposing (..)
import Task exposing (Task)
import Date exposing (Date)
import Model exposing (..)


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
