module DateUtils (..) where

import List exposing (head)
import Date exposing (..)
import Date.Core exposing (..)
import Date.Utils exposing (..)
import Date.Period as Period exposing (add, diff)
import Date.Compare as Compare exposing (is, Compare2)
import Date.Format exposing (isoString)
import Date.Floor as Df exposing (floor)
import Model exposing (..)


enteredHoursVsTotal : Model -> Float
enteredHoursVsTotal model =
  let
    enteredHours =
      List.foldl
        (\dateEntries -> totalHoursForDate dateEntries)
        0
        model.entries
  in
    enteredHours - totalHoursForYear model


totalHoursForDate : DateEntries -> Float -> Float
totalHoursForDate dateEntries hours =
  let
    hourList =
      List.map
        (\entry ->
          if entry.taskId == 4905852 then
            -- Vuosiloma
            0
          else
            entry.hours
        )
        dateEntries.entries
  in
    hours + List.sum hourList


totalHoursForYear : Model -> Float
totalHoursForYear model =
  toFloat (List.length (totalDaysForYear model)) * 7.5


totalDaysForYear : Model -> List Date
totalDaysForYear model =
  workDays (isoWeekOne (year model.currentDate)) model []


workDays : Date -> Model -> List Date -> List Date
workDays date model days =
  if isSameDate date model.currentDate then
    days
  else
    let
      nextDay =
        add Period.Day 1 date

      dayList =
        if
          isWorkDay nextDay
            && List.length
                (List.filter
                  (\holiday -> isSameDate holiday.date nextDay)
                  model.holidays
                )
            == 0
        then
          nextDay :: days
        else
          days
    in
      workDays nextDay model dayList


isSameDate : Date -> Date -> Bool
isSameDate date1 date2 =
  is
    Compare.Same
    (Df.floor Df.Day date1)
    (Df.floor Df.Day date2)


isWorkDay : Date -> Bool
isWorkDay date =
  let
    dow =
      dayOfWeek date
  in
    not (dow == Sat || dow == Sun)
