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
            ]
        , navigationPane address model
        , calendarTable model
        ]


navigationPane : Address Action -> Model -> Html
navigationPane address model =
  div
    [ class "navigation" ]
    [ div
        []
        [ button
            [ onClick address PreviousMonth, class "float-left" ]
            [ i [ class "fa fa-arrow-left" ] [] ]
        ]
    , div
        []
        [ button
            [ onClick address NextMonth ]
            [ i [ class "fa fa-arrow-right" ] [] ]
        ]
    , div [] [ i [ class (spinnerClass model) ] [] ]
    ]


spinnerClass : Model -> String
spinnerClass model =
  if (Debug.log "loading" model.loading) then
    "fa fa-spinner fa-pulse"
  else
    ""


calendarTable : Model -> Html
calendarTable model =
  table
    [ class "calendar" ]
    [ thead
        []
        [ tr
            []
            []
        ]
    , tbody
        []
        (List.map
          (\week -> weekRow model week)
          (monthView model)
        )
    ]


weekRow : Model -> List DateHours -> Html
weekRow model dateEntries =
  tr
    []
    (List.map
      (\day ->
        td
          [ class (dayCellClass model day) ]
          [ div [] [ text (dateFormat day.date) ]
          , div [] [ text (toString day.hours) ]
          ]
      )
      dateEntries
    )


dayCellClass : Model -> DateHours -> String
dayCellClass model dateHours =
  if List.member (dayOfWeek dateHours.date) [ Date.Sat, Date.Sun ] then
    "weekend"
  else if month dateHours.date == month model.currentDate then
    "current-month"
  else
    "other-month"
