module DateUtils exposing (addDailyHours, calculateDailyHours, calculateHourBalance, dateFormat, dateInCurrentMonth, dayHasOnlySpecialTasks, entryHours, hourBalanceOfCurrentMonth, isHoliday, isSameDate, isSpecialTask, isWeekDay, isWorkDay, sumHours, totalDaysForYear, totalHoursForMonth, totalHoursForYear, workDays, lastOfMonthDate, firstOfMonthDate, isStartAfterEnd)

import Date exposing (..)
import Time exposing (Month(..), Weekday(..))
import List exposing (drop, head, isEmpty, reverse, take)
import Model exposing (..)


calculateHourBalance : Model -> Hours {}
calculateHourBalance model =
    let
        dateHourList =
            List.map (\dateEntries -> calculateDailyHours dateEntries model)
                model.entries

        totalHours =
            sumHours dateHourList

        normalHourBalance =
            .normalHours totalHours
                - totalHoursForYear model
                + model.previousBalance
    in
    { totalHours | normalHours = normalHourBalance }


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
    .normalHours (sumHours dateHourList) - totalHoursForMonth model


sumHours : List (Hours a) -> Hours {}
sumHours dateHours =
    List.foldl addDailyHours
        { normalHours = 0, kikyHours = 0 }
        dateHours


addDailyHours : Hours a -> Hours b -> Hours {}
addDailyHours a b =
    { normalHours =
        a.normalHours + b.normalHours
    , kikyHours = a.kikyHours + b.kikyHours
    }


dateInCurrentMonth : Date -> Date -> Bool
dateInCurrentMonth date currentDate =
    isBetween
        (firstOfMonthDate currentDate)
        (lastOfMonthDate currentDate)
        date


isSpecialTask : Entry -> SpecialTasks -> Bool
isSpecialTask entry specialTasks =
    List.any (\t -> t.id == entry.taskId)
        (List.append specialTasks.kiky specialTasks.ignore)


calculateDailyHours : DateEntries -> Model -> DateHours
calculateDailyHours dateEntries model =
    let
        normalHours =
            List.sum
                (List.map
                    (\entry ->
                        if isSpecialTask entry model.specialTasks then
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
                        if
                            (year dateEntries.date == year model.currentDate)
                                && List.any (\t -> t.id == entry.taskId) model.specialTasks.kiky
                        then
                            entry.hours

                        else
                            0
                    )
                    dateEntries.entries
                )
    in
    { date = dateEntries.date
    , normalHours = normalHours
    , kikyHours = kikyHours
    }


entryHours : Entry -> SpecialTasks -> Float
entryHours entry specialTasks =
    if List.any (\t -> t.id == entry.taskId) specialTasks.ignore then
        0

    else
        entry.hours

lastOfMonthDate : Date -> Date
lastOfMonthDate date =
    (add Days -1 (add Months 1 (fromCalendarDate (year date) (month date) 1)))

firstOfMonthDate : Date -> Date
firstOfMonthDate date =
    fromCalendarDate (year date) (month date) 1

totalHoursForMonth : Model -> Float
totalHoursForMonth model =
    let
        endDate =
            if dateInCurrentMonth model.currentDate model.today then
                model.today

            else
                lastOfMonthDate model.currentDate

        dayList =
            workDays (firstOfMonthDate model.currentDate) endDate model.holidays []
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

isStartAfterEnd : Date -> Date -> Bool
isStartAfterEnd startDate endDate =
    (Date.compare startDate endDate) == GT

workDays : Date -> Date -> List Holiday -> List Date -> List Date
workDays startDate endDate holidays days =
    if isStartAfterEnd startDate endDate then
        days

    else
        let
            nextDay =
                add Days 1 startDate

            dayList =
                if isWorkDay startDate holidays then
                    startDate :: days

                else
                    days
        in
        workDays nextDay endDate holidays dayList


dayHasOnlySpecialTasks : DateEntries -> SpecialTasks -> Bool
dayHasOnlySpecialTasks dateEntries specialTasks =
    List.foldl
        (\entry bool -> isSpecialTask entry specialTasks && bool)
        (not (List.isEmpty dateEntries.entries))
        dateEntries.entries


isWorkDay : Date -> List Holiday -> Bool
isWorkDay date holidays =
    isWeekDay date && not (isHoliday date holidays)


isHoliday : Date -> List Holiday -> Bool
isHoliday date holidays =
    List.any (\holiday -> isSameDate holiday.date date) holidays


isSameDate : Date -> Date -> Bool
isSameDate date1 date2 =
    (Date.compare date1 date2) == EQ


isWeekDay : Date -> Bool
isWeekDay date =
    not (List.member (weekday date) [ Sat, Sun ])


dateFormat : Date -> String
dateFormat date =
    format "dd.MM." date
