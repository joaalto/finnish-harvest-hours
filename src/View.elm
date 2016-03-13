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
            [ onClick address NextMonth, class "float-left" ]
            [ i [ class "fa fa-arrow-right" ] [] ]
        ]
    , div [ class "spinner" ] [ i [ class (spinnerClass model) ] [] ]
    ]


spinnerClass : Model -> String
spinnerClass model =
  if model.loading then
    "fa fa-spinner fa-pulse spinner"
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
          , div [] [ dayHours day ]
          ]
      )
      dateEntries
    )


dayHours : DateHours -> Html
dayHours day =
  if day.hours == 0 then
    text ""
  else
    text (toString day.hours)


dayCellClass : Model -> DateHours -> String
dayCellClass model dateHours =
  if List.member (dayOfWeek dateHours.date) [ Date.Sat, Date.Sun ] then
    "weekend"
  else if month dateHours.date == month model.currentDate then
    "current-month"
  else
    "other-month"
