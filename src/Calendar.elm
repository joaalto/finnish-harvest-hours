module Calendar exposing (..)

import List exposing (head, isEmpty, reverse, drop, take)
import Date exposing (..)
import Date.Extra.Period as Period exposing (add, diff)
import Date.Extra.Core exposing (..)
import Date.Extra.Utils as DEU
import Date.Extra.Compare as Compare exposing (is, Compare2, Compare3)
import Model exposing (..)
import DateUtils exposing (..)


{-|
  Set up calendar table data.
-}
monthView : Model -> List (List DateEntries)
monthView model =
    weekRows (monthDays model) []


weekRows : List DateEntries -> List (List DateEntries) -> List (List DateEntries)
weekRows entryList result =
    if (isEmpty entryList) then
        reverse result
    else
        weekRows (drop 7 entryList) ((take 7 entryList) :: result)


monthDays : Model -> List DateEntries
monthDays model =
    let
        dayOffset =
            firstOfMonthDayOfWeek model.currentDate
    in
        dateRange model.entries
            (add Period.Day -dayOffset (toFirstOfMonth model.currentDate))
            dayOffset


dateRange : List DateEntries -> Date -> Int -> List DateEntries
dateRange dateEntries startDate offset =
    let
        dayList =
            DEU.dayList ((daysInMonthDate startDate) + offset) startDate
    in
        List.map
            (\day ->
                Maybe.withDefault
                    { date = day, entries = [] }
                    (singleDaysEntries dateEntries day)
            )
            dayList


singleDaysEntries : List DateEntries -> Date -> Maybe DateEntries
singleDaysEntries dateEntries date =
    List.head
        (List.filter (\dateEntries -> isSameDate date dateEntries.date)
            dateEntries
        )


{-| Day of week of the first day of the month as Int, from 0 (Mon) to 6 (Sun).
-}
firstOfMonthDayOfWeek : Date -> Int
firstOfMonthDayOfWeek currentDate =
    isoDayOfWeek (dayOfWeek (toFirstOfMonth currentDate)) - 1
