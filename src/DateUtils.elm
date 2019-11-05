module DateUtils exposing (..)

import List
import Date exposing (..)
import Date.Extra.Core exposing (..)
import Date.Extra.Period as Period exposing (add)
import Date.Extra.Compare as Compare exposing (is, Compare2, Compare3)
import Date.Extra.Format exposing (format)
import Date.Extra.Config.Configs as DateConfigs
import Date.Extra.TimeUnit as TimeUnit
import Model exposing (..)

defaultDailyHours = 7.5

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
                - (totalWorkHours model)
                + (hoursForVariantPeriods model)
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
        .normalHours (sumHours dateHourList)
            - (totalHoursForMonth model)
            + (monthlyHoursForVariantPeriods model)

hoursForVariantPeriod : Model -> VariantPeriod -> Float
hoursForVariantPeriod model variantPeriod =
    let
        dailyDifference = defaultDailyHours - variantPeriod.dailyHours

        firstWorkDate =
            model.entries
                |> List.head
                |> Maybe.map .date
                |> Maybe.withDefault model.today

        givenStartDate = Maybe.withDefault firstWorkDate variantPeriod.start

        startDate =
            if Compare.is Compare.After firstWorkDate givenStartDate then
                firstWorkDate
            else
                givenStartDate

        givenEndDate = Maybe.withDefault model.today variantPeriod.end

        endDate =
            if Compare.is Compare.After givenEndDate model.today then
                model.today
            else
                givenEndDate

        dayList =
            workDays startDate endDate model.holidays []

    in
        toFloat (List.length dayList) * dailyDifference


hoursForVariantPeriods : Model -> Float
hoursForVariantPeriods model =
    List.sum (
        List.map (\variantPeriods -> hoursForVariantPeriod model variantPeriods)
                  model.user.variantPeriods)


isVariantPeriodInMonth : Date -> VariantPeriod -> Bool
isVariantPeriodInMonth currentDate variantPeriod =
    let
        firstOfMonth = toFirstOfMonth currentDate
        lastOfMonth = lastOfMonthDate currentDate

        startDate = case variantPeriod.start of
            Nothing -> firstOfMonth
            Just start -> start

        endDate = case variantPeriod.end of
            Nothing -> currentDate
            Just end -> end

        isStartInMonth =
            dateInCurrentMonth startDate currentDate

        isEndInMonth =
            dateInCurrentMonth endDate currentDate

        lastsWholeMonth =
            (Compare.is Compare.After firstOfMonth startDate) &&
            (Compare.is Compare.After endDate lastOfMonth)

    in
        isStartInMonth || isEndInMonth || lastsWholeMonth

{-| Assuming here that this variantPeriod has already been checked to actually overlap the current month.
-}
monthlyHoursForVariantPeriod : Model -> VariantPeriod -> Float
monthlyHoursForVariantPeriod model variantPeriod =
    let
        dailyDifference = defaultDailyHours - variantPeriod.dailyHours

        firstOfMonth = startOfMonth model

        startDate = case variantPeriod.start of
            Nothing -> firstOfMonth
            Just start ->
                if Compare.is Compare.After firstOfMonth start then
                    firstOfMonth
                else
                    start

        endDate = case variantPeriod.end of
            Nothing -> model.currentDate
            Just end ->
                if Compare.is Compare.After end model.currentDate then
                    model.currentDate
                else
                    end

        dayList =
            workDays startDate endDate model.holidays []

    in
        toFloat (List.length dayList) * dailyDifference


monthlyHoursForVariantPeriods : Model -> Float
monthlyHoursForVariantPeriods model =
    let
        variantPeriodsInMonth = List.filter
            (\variantPeriod -> isVariantPeriodInMonth model.currentDate variantPeriod)
            model.user.variantPeriods

        hoursForPeriods = List.map
            (\variantPeriod -> monthlyHoursForVariantPeriod model variantPeriod)
            variantPeriodsInMonth
    in
        List.sum(hoursForPeriods)


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
                            (year (dateEntries.date) == year (model.currentDate))
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

totalHoursForMonth : Model -> Float
totalHoursForMonth model =
    let
        endDate =
            if dateInCurrentMonth model.currentDate model.today then
                model.today
            else
                lastOfMonthDate model.currentDate

        dayList =
            workDays (startOfMonth model) endDate model.holidays []
    in
        toFloat (List.length dayList) * defaultDailyHours

startOfMonth : Model -> Date
startOfMonth model =
    let
        firstEmploymentDate =
            model.entries
                |> List.head
                |> Maybe.map .date

    in
        case firstEmploymentDate of
            Nothing ->
                toFirstOfMonth model.currentDate
            Just firstDate ->
                if dateInCurrentMonth model.currentDate firstDate then
                    firstDate
                else
                    toFirstOfMonth model.currentDate


totalWorkHours : Model -> Float
totalWorkHours model =
    toFloat (List.length (totalWorkDays model)) * defaultDailyHours


totalWorkDays : Model -> List Date
totalWorkDays model =
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
