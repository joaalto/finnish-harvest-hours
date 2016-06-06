module View exposing  (..)

import List
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import DateUtils exposing (..)
import Date exposing (..)
import String
import Model exposing (..)
import Update exposing (..)


view : Model -> Html Msg
view model =
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
                  [ (String.join " " [ model.user.firstName, model.user.lastName ])
                  , String.join " " [ "Tuntisaldo:", (hourString model.totalHours), "h" ]
                  ]
                )
            ]
        , navigationPane model
        , calendarTable model
        ]


navigationPane : Model -> Html Msg
navigationPane model =
  div
    [ class "navigation" ]
    [ div
        []
        [ button
            [ onClick PreviousMonth, class "float-left" ]
            [ i [ class "fa fa-arrow-left" ] [] ]
        ]
    , div
        []
        [ button
            [ onClick NextMonth, class "float-left" ]
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


calendarTable : Model -> Html Msg
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


weekRow : Model -> List DateHours -> Html Msg
weekRow model dateEntries =
  tr
    []
    (List.map
      (\day ->
        td
          [ class (dayCellClass model day) ]
          [ div [] [ text (dateFormat day.date) ]
          , div [ class "hours" ] [ text (hourString day.hours) ]
          ]
      )
      dateEntries
    )


hourString : Float -> String
hourString hours =
  if hours == 0 then
    ""
  else
    toString hours


dayCellClass : Model -> DateHours -> String
dayCellClass model dateHours =
  if not (isWorkDay dateHours.date model) then
    "day-off"
  else if month dateHours.date == month model.currentDate then
    "current-month"
  else
    "other-month"
