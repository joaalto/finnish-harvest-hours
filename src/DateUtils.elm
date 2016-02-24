module DateUtils (..) where

import List exposing (head)
import Date exposing (..)
import Date.Core exposing (..)
import Date.Utils exposing (..)
import Date.Period as Period exposing (add, diff)
import Date.Compare exposing (is, Compare2)


-- totalHoursForYear : Date -> Float


totalDaysForYear : Date -> List Date
totalDaysForYear currentDate =
  workDays (Debug.log "firstDay" (isoWeekOne (year currentDate))) currentDate []


workDays : Date -> Date -> List Date -> List Date
workDays date currentDate days =
  if (is Date.Compare.Same currentDate date) then
    days
  else
    let
      nextDay =
        add Period.Day 1 date
    in
      workDays (Debug.log "nextDay" nextDay) currentDate (nextDay :: days)
