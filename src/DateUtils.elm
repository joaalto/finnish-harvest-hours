module DateUtils (..) where

import List exposing (head, isEmpty, reverse, drop, take)
import Date exposing (..)
import Date.Core exposing (..)
import Date.Period as Period exposing (add, diff)
import Date.Compare as Compare exposing (is, Compare2)
import Date.Format exposing (format)
import Date.Config.Configs as DateConfigs
import Date.Floor as Df exposing (floor)
import Model exposing (..)


type alias DateHours =
  { date : Date
  , hours : Float
  }


enteredHoursVsTotal : Model -> Float
enteredHoursVsTotal model =
  let
    debug =
      Debug.log
        "dataAvailable"
        (not
          (isEmpty model.entries
            || isEmpty model.holidays
            || isEmpty model.absenceTasks
          )
        )

    enteredHours =
      List.sum
        (List.concatMap
          (\dateEntries -> hoursForDate dateEntries model)
          model.entries
        )
  in
    enteredHours - totalHoursForYear model


hoursForDate : DateEntries -> Model -> List Float
hoursForDate dateEntries model =
  List.map
    (\entry ->
      if not (isAbsence entry model) then
        entry.hours
      else
        0
    )
    dateEntries.entries


isAbsence : Entry -> Model -> Bool
isAbsence entry model =
  let
    taskIds =
      List.map .id model.absenceTasks
  in
    List.member entry.taskId taskIds


totalHoursForYear : Model -> Float
totalHoursForYear model =
  toFloat (List.length (totalDaysForYear model)) * 7.5


totalDaysForYear : Model -> List Date
totalDaysForYear model =
  workDays (Df.floor Df.Year model.today) model []


workDays : Date -> Model -> List Date -> List Date
workDays date model days =
  if isSameDate date model.today then
    days
  else
    let
      nextDay =
        add Period.Day 1 date

      dayList =
        if isWorkDay nextDay model then
          nextDay :: days
        else
          days
    in
      workDays nextDay model dayList


isWorkDay : Date -> Model -> Bool
isWorkDay date model =
  isWeekDay date && not (isHoliday date model)


isHoliday : Date -> Model -> Bool
isHoliday date model =
  List.length
    (List.filter
      (\holiday -> isSameDate holiday.date date)
      model.holidays
    )
    > 0


isSameDate : Date -> Date -> Bool
isSameDate date1 date2 =
  is
    Compare.Same
    (floorDay date1)
    (floorDay date2)


isWeekDay : Date -> Bool
isWeekDay date =
  not (List.member (dayOfWeek date) [ Sat, Sun ])


floorDay : Date -> Date
floorDay date =
  Df.floor Df.Day date


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
  dateRange
    model
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
    dateRange
      model
      (add Period.Hour 3 (add Period.Day 1 (floorDay startDate)))
      endDate
      ({ date = startDate, hours = (sumDateHours model startDate) } :: dateList)


{-| Total entered hours for a date.
-}
sumDateHours : Model -> Date -> Float
sumDateHours model date =
  let
    dateEntries =
      List.filter
        (\dateEntries -> isSameDate date dateEntries.date)
        model.entries
  in
    List.sum
      (List.concatMap
        (\dateEntries -> hoursForDate dateEntries model)
        dateEntries
      )


{-| Day of week of the first day of the month as Int, from 0 (Mon) to 6 (Sun).
-}
firstOfMonthDayOfWeek : Model -> Int
firstOfMonthDayOfWeek model =
  isoDayOfWeek (dayOfWeek (toFirstOfMonth model.currentDate)) - 1


dateFormat : Date -> String
dateFormat date =
  format (DateConfigs.getConfig "en_us") "%d.%m." date
