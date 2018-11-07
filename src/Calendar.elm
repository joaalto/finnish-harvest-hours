module Calendar exposing (dateRange, firstOfMonthDayOfWeek, monthDays, monthView, singleDaysEntries, sumDateHours, weekRows)

import Date exposing (Date, Unit(..), add, weekdayNumber)
import DateUtils exposing (..)
import List exposing (drop, head, isEmpty, reverse, take)
import Model exposing (..)
import Time exposing (Month(..), utc)
import Time.Extra as Time


{-| Set up calendar table data.
-}
monthView : Model -> List (List DateEntries)
monthView model =
    weekRows (monthDays model) []


weekRows : List DateEntries -> List (List DateEntries) -> List (List DateEntries)
weekRows entryList result =
    if isEmpty entryList then
        reverse result

    else
        weekRows (drop 7 entryList) (take 7 entryList :: result)


monthDays : Model -> List DateEntries
monthDays model =
    dateRange model
        (Date.add Days -(firstOfMonthDayOfWeek model.currentDate) (firstOfMonthDate model.currentDate))
        (lastOfMonthDate model.currentDate)
        []


{-| Build a list of days with sum of entered hours.
-}
dateRange : Model -> Date -> Date -> List DateEntries -> List DateEntries
dateRange model startDate endDate dateList =
    if isStartAfterEnd startDate endDate then
        reverse dateList

    else
        let
            mDateEntries =
                singleDaysEntries model startDate

            dateEntries =
                case mDateEntries of
                    Nothing ->
                        { date = startDate, entries = [] }

                    Just val ->
                        val

            nextDay =
                add Days 1 startDate
        in
        dateRange model
            nextDay
            endDate
            (dateEntries :: dateList)


singleDaysEntries : Model -> Date -> Maybe DateEntries
singleDaysEntries model date =
    List.head
        (List.filter (\dateEntries -> isSameDate date dateEntries.date)
            model.entries
        )


{-| Total entered hours for a date.
-}
sumDateHours : Model -> Date -> DateHours
sumDateHours model date =
    let
        dateEntries =
            List.head
                (List.filter (\entries -> isSameDate date entries.date)
                    model.entries
                )
    in
    case dateEntries of
        Nothing ->
            { date = date
            , normalHours = 0
            , kikyHours = 0
            }

        Just entries ->
            calculateDailyHours entries model


{-| Day of week of the first day of the month as Int, from 0 (Mon) to 6 (Sun).
-}
firstOfMonthDayOfWeek : Date -> Int
firstOfMonthDayOfWeek date =
    weekdayNumber (firstOfMonthDate date) - 1
