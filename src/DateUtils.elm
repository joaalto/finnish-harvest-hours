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
    enteredHours - totalHoursForYear model.currentDate


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


totalHoursForYear : Date -> Float
totalHoursForYear currentDate =
  toFloat (List.length (totalDaysForYear currentDate)) * 7.5


totalDaysForYear : Date -> List Date
totalDaysForYear currentDate =
  workDays (isoWeekOne (year currentDate)) currentDate []


workDays : Date -> Date -> List Date -> List Date
workDays date currentDate days =
  if isSameDate date currentDate then
    days
  else
    let
      nextDay =
        add Period.Day 1 date

      dayList =
        if isWorkDay nextDay then
          nextDay :: days
        else
          days
    in
      workDays nextDay currentDate dayList


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
