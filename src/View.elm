module View (..) where

import List exposing (take)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import DateUtils exposing (..)
import Date exposing (..)
import String
import Model exposing (..)
import Update exposing (..)
import Date.Core exposing (daysInMonthDate, isoDayOfWeek)
import Date.Format exposing (isoString)


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
              , (toString (List.length (totalDaysForYear model)))
              , (String.join " " [ model.user.firstName, model.user.lastName ])
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
    , tbody
        []
        (List.map
          (\week -> weekRow week)
          (monthView model)
        )
    ]


weekRow : List DateEntries -> Html
weekRow dateEntries =
  tr
    []
    (List.map
      (\day -> td [ value (isoString day.date) ] [])
      dateEntries
    )


{-| How many week rows do we need to render for the current month
-}
calRowCount : Model -> Int
calRowCount model =
  ceiling
    (toFloat
      (firstOfMonthDayOfWeek model + (daysInMonthDate model.currentDate))
      / 7
    )
