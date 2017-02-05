module DateUtils exposing (..)

import List exposing (head, isEmpty, reverse, drop, take)
import Date exposing (..)
import Date.Extra.Core exposing (..)
import Date.Extra.Period as Period exposing (add, diff)
import Date.Extra.Compare as Compare exposing (is, Compare2, Compare3)
import Date.Extra.Format exposing (format)
import Date.Extra.Config.Configs as DateConfigs
import Date.Extra.TimeUnit as TimeUnit
import Model exposing (..)


enteredHoursVsTotal : Model -> Float
enteredHoursVsTotal model =
    let
        dateHourList =
            List.map (\dateEntries -> calculateDailyHours dateEntries model)
                model.entries
    in
        (normalHoursToFloat (sumHours dateHourList)) - (totalHoursForYear model) + model.previousBalance


hourBalanceOfCurrentMonth : Model -> Float
hourBalanceOfCurrentMonth model =
    let
        currentMonthEntries =
            List.filter (\entry -> dateInCurrentMonth entry.date model.currentDate)
                model.entries

        dateHourList =
            List.map (\dateEntries -> calculateDailyHours dateEntries model)
                currentMonthEntries
    in
        (normalHoursToFloat (sumHours dateHourList)) - (totalHoursForMonth model)


sumHours : List (Hours a) -> Hours {}
sumHours dateHours =
    List.foldl addDailyHours
        { normalHours = (NormalHours 0), kikyHours = (KikyHours 0) }
        dateHours


addDailyHours : Hours a -> Hours b -> Hours {}
addDailyHours a b =
    { normalHours =
        (plus a.normalHours b.normalHours)
    , kikyHours = (plusKiky a.kikyHours b.kikyHours)
    }


plus : NormalHours -> NormalHours -> NormalHours
plus (NormalHours a) (NormalHours b) =
    NormalHours (a + b)


plusKiky : KikyHours -> KikyHours -> KikyHours
plusKiky (KikyHours a) (KikyHours b) =
    KikyHours (a + b)


normalHoursToFloat : Hours a -> Float
normalHoursToFloat { normalHours } =
    let
        (NormalHours float) =
            normalHours
    in
        float


dateInCurrentMonth : Date -> Date -> Bool
dateInCurrentMonth date currentDate =
    Compare.is3 Compare.BetweenOpenEnd
        date
        (lastOfPrevMonthDate currentDate)
        (lastOfMonthDate currentDate)


calculateDailyHours : DateEntries -> Model -> DateHours
calculateDailyHours dateEntries model =
    let
        normalHours =
            List.sum
                (List.map
                    (\entry ->
                        if
                            List.any (\t -> t.id == entry.taskId)
                                (List.append model.specialTasks.kiky model.specialTasks.ignore)
                        then
                            0
                        else
                            entry.hours
                    )
                    dateEntries.entries
                )

        kikyHours =
            List.sum
                (List.map
                    (\entry ->
                        if List.any (\t -> t.id == entry.taskId) model.specialTasks.kiky then
                            entry.hours
                        else
                            0
                    )
                    dateEntries.entries
                )
    in
        { date = dateEntries.date
        , normalHours = (NormalHours normalHours)
        , kikyHours = (KikyHours kikyHours)
        }


entryHours : Entry -> SpecialTasks -> Float
entryHours entry specialTasks =
    if List.any (\t -> t.id == entry.taskId) specialTasks.ignore then
        0
    else
        entry.hours


totalHoursForMonth : Model -> Float
totalHoursForMonth model =
    let
        endDate =
            if dateInCurrentMonth model.currentDate model.today then
                model.today
            else
                lastOfMonthDate model.currentDate

        dayList =
            workDays (toFirstOfMonth model.currentDate) endDate model.holidays []
    in
        toFloat (List.length dayList) * 7.5


totalHoursForYear : Model -> Float
totalHoursForYear model =
    toFloat (List.length (totalDaysForYear model)) * 7.5


totalDaysForYear : Model -> List Date
totalDaysForYear model =
    model.entries
        |> List.head
        |> Maybe.map (\entry -> workDays entry.date model.today model.holidays [])
        |> Maybe.withDefault []


workDays : Date -> Date -> List Holiday -> List Date -> List Date
workDays startDate endDate holidays days =
    if Compare.is Compare.After startDate endDate then
        days
    else
        let
            nextDay =
                add Period.Day 1 startDate

            dayList =
                if isWorkDay startDate holidays then
                    startDate :: days
                else
                    days
        in
            workDays nextDay endDate holidays dayList


isWorkDay : Date -> List Holiday -> Bool
isWorkDay date holidays =
    isWeekDay date && not (isHoliday date holidays)


isHoliday : Date -> List Holiday -> Bool
isHoliday date holidays =
    List.length
        (List.filter (\holiday -> isSameDate holiday.date date)
            holidays
        )
        > 0


isSameDate : Date -> Date -> Bool
isSameDate date1 date2 =
    is Compare.Same
        (startOfDate date1)
        (startOfDate date2)


isWeekDay : Date -> Bool
isWeekDay date =
    not (List.member (dayOfWeek date) [ Sat, Sun ])


startOfDate : Date -> Date
startOfDate date =
    TimeUnit.startOfTime TimeUnit.Day date


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


dateFormat : Date -> String
dateFormat date =
    format (DateConfigs.getConfig "en_us") "%d.%m." date
