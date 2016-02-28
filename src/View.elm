module View (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import DateUtils exposing (..)
import Date exposing (..)
import String
import Model exposing (..)
import Update exposing (..)


view : Address Action -> Model -> Html
view address model =
  case model.httpError of
    Err err ->
      div
        [ style [ ( "color", "red" ) ] ]
        [ text (toString err) ]

    Ok _ ->
      div
        []
        [ text
            (String.join
              ", "
              [ (toString (Date.dayOfWeek model.currentDate))
              , (toString (List.length (totalDaysForYear model.currentDate)))
              , (toString model.totalHours)
              ]
            )
        , calendarTable model
        ]


calendarTable : Model -> Html
calendarTable model =
  table
    []
    [ thead
        []
        [ tr
            []
            []
        ]
    ]



-- weekHeader
