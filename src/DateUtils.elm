module DateUtils (..) where

import List exposing (head)
import Date exposing (..)
import Date.Core exposing (..)
import Date.Utils exposing (..)
import Date.Period as Period exposing (add, diff)
import Date.Compare as Compare exposing (is, Compare2)
import Date.Format exposing (isoString)
import Date.Floor as Df exposing (floor)


-- totalHoursForYear : Date -> Float


totalDaysForYear : Date -> List Date
totalDaysForYear currentDate =
  workDays (Debug.log "firstDay" (isoWeekOne (year currentDate))) currentDate []


workDays : Date -> Date -> List Date -> List Date
workDays date currentDate days =
  if isSameDate date currentDate then
    days
  else
    let
      nextDay =
        add Period.Day 1 date

      isoStr =
        (Debug.log "nextDay" (isoString nextDay))
    in
      workDays nextDay currentDate (nextDay :: days)


isSameDate : Date -> Date -> Bool
isSameDate date1 date2 =
  is
    Compare.Same
    (Df.floor Df.Day date1)
    (Df.floor Df.Day date2)
