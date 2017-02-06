module Calendar exposing (..)

import List exposing (head, isEmpty, reverse, drop, take)
import Date exposing (..)
import Date.Extra.Period as Period exposing (add, diff)
import Date.Extra.Core exposing (..)
import Date.Extra.Compare as Compare exposing (is, Compare2, Compare3)
import Model exposing (..)
import DateUtils exposing (..)


{-|
  Set up calendar table data.
-}
monthView : Model -> List (List DateHours)
monthView model =
    weekRows (monthDays model) []


weekRows : List DateHours -> List (List DateHours) -> List (List DateHours)
weekRows entryList result =
    if (isEmpty entryList) then
        reverse result
    else
        weekRows (drop 7 entryList) ((take 7 entryList) :: result)


monthDays : Model -> List DateHours
monthDays model =
    dateRange model
        (add Period.Day -(firstOfMonthDayOfWeek model) (toFirstOfMonth model.currentDate))
        (lastOfMonthDate model.currentDate)
        []


{-|
  Build a list of days with sum of entered hours.
  Set hour at 3 hours past midnight to avoid DST problems.
-}
dateRange : Model -> Date -> Date -> List DateHours -> List DateHours
dateRange model startDate endDate dateList =
    if Compare.is Compare.After startDate endDate then
        reverse dateList
    else
        dateRange model
            (add Period.Hour 3 (add Period.Day 1 (startOfDate startDate)))
            endDate
            (sumDateHours model startDate
                :: dateList
            )


{-| Total entered hours for a date.
-}
sumDateHours : Model -> Date -> DateHours
sumDateHours model date =
    let
        dateEntries =
            List.head
                (List.filter (\dateEntries -> isSameDate date dateEntries.date)
                    model.entries
                )
    in
        case dateEntries of
            Nothing ->
                { date = date
                , normalHours = NormalHours 0
                , kikyHours = KikyHours 0
                }

            Just entries ->
                calculateDailyHours entries model


{-| Day of week of the first day of the month as Int, from 0 (Mon) to 6 (Sun).
-}
firstOfMonthDayOfWeek : Model -> Int
firstOfMonthDayOfWeek model =
    isoDayOfWeek (dayOfWeek (toFirstOfMonth model.currentDate)) - 1
