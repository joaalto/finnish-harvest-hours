module Api (..) where

import Http exposing (Error)
import Json.Decode as Json exposing (..)
import Task exposing (Task)
import Date exposing (Date)
import Model exposing (Entry)


getEntries : Task Error (List Entry)
getEntries =
  Http.get decodeEntries "/entries"


decodeEntries : Json.Decoder (List Entry)
decodeEntries =
  list
    (object2
      Entry
      ("date" := customDecoder string Date.fromString)
      ("hours" := float)
    )
