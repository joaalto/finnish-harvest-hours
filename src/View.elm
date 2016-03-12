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


view : Address Action -> Model -> Html
view address model =
  case model.httpError of
    Err err ->
      div
        [ style [ ( "color", "red" ) ] ]
        [ text (toString err) ]

    Ok _ ->
      div
        [ class "main" ]
        [ div
            [ class "header" ]
            [ text
                (String.join
                  " | "
                  [ (toString (Date.dayOfWeek model.currentDate))
                  , dateFormat model.currentDate
                  , (toString (List.length (totalDaysForYear model)))
                  , (String.join " " [ model.user.firstName, model.user.lastName ])
                  , (toString model.totalHours)
                  ]
                )
            , navigationPane address model
            , calendarTable model
            ]
        ]


navigationPane : Address Action -> Model -> Html
navigationPane address model =
  div
    [ class "navigation" ]
    [ div
        []
        [ button
            [ onClick address PreviousMonth ]
            [ text "<" ]
        ]
    , div
        []
        [ button
            [ onClick address NextMonth ]
            [ text ">" ]
        ]
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


weekRow : List DateHours -> Html
weekRow dateEntries =
  tr
    []
    (List.map
      (\day ->
        td
          []
          [ div [] [ text (dateFormat day.date) ]
          , div [] [ text (toString day.hours) ]
          ]
      )
      dateEntries
    )
