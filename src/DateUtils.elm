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


calculateHourBalance : Model -> Hours {}
calculateHourBalance model =
    let
        dateHourList =
            List.map (\dateEntries -> calculateDailyHours dateEntries model.specialTasks)
                model.entries

        totalHours =
            sumHours dateHourList

        normalHourBalance =
            .normalHours totalHours
                - (totalHoursForYear model)
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
            List.map (\dateEntries -> calculateDailyHours dateEntries model.specialTasks)
                currentMonthEntries
    in
        .normalHours (sumHours dateHourList) - (totalHoursForMonth model)


sumHours : List (Hours a) -> Hours {}
sumHours dateHours =
    List.foldl addDailyHours
        { normalHours = 0, kikyHours = 0 }
        dateHours


addDailyHours : Hours a -> Hours b -> Hours {}
addDailyHours a b =
    { normalHours =
        (a.normalHours + b.normalHours)
    , kikyHours = (a.kikyHours + b.kikyHours)
    }


dateInCurrentMonth : Date -> Date -> Bool
dateInCurrentMonth date currentDate =
    Compare.is3 Compare.Between
        (startOfDate date)
        (endOfDate (lastOfPrevMonthDate currentDate))
        (startOfDate (firstOfNextMonthDate currentDate))


isSpecialTask : Entry -> SpecialTasks -> Bool
isSpecialTask entry specialTasks =
    List.any (\t -> t.id == entry.taskId)
        (List.append specialTasks.kiky specialTasks.ignore)


calculateDailyHours : DateEntries -> SpecialTasks -> DateHours
calculateDailyHours dateEntries specialTasks =
    let
        normalHours =
            List.sum
                (List.map
                    (\entry ->
                        if isSpecialTask entry specialTasks then
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
                        if List.any (\t -> t.id == entry.taskId) specialTasks.kiky then
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


dayHasOnlySpecialTasks : DateEntries -> SpecialTasks -> Bool
dayHasOnlySpecialTasks dateEntries specialTasks =
    List.foldl
        (\entry bool -> (isSpecialTask entry specialTasks) && bool)
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
    is Compare.Same
        (startOfDate date1)
        (startOfDate date2)


isWeekDay : Date -> Bool
isWeekDay date =
    not (List.member (dayOfWeek date) [ Sat, Sun ])


startOfDate : Date -> Date
startOfDate date =
    TimeUnit.startOfTime TimeUnit.Day date


endOfDate : Date -> Date
endOfDate date =
    TimeUnit.endOfTime TimeUnit.Day date


dateFormat : Date -> String
dateFormat date =
    format (DateConfigs.getConfig "en_us") "%d.%m." date
