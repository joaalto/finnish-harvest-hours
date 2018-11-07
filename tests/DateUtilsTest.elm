module DateUtilsTest exposing (all)

import Date exposing (Unit(..), fromCalendarDate, fromPosix)
import Time exposing (millisToPosix, utc)
import DateUtils exposing (..)
import Expect
import Material
import Model exposing (..)
import Test exposing (..)
import Time exposing (Month(..))


all : Test
all =
    describe "Date utils"
        [ test "only entries within current month are added up" <|
            \() ->
                let
                    model =
                        { initialModel
                            | currentDate = fromCalendarDate 2017 Mar 5
                            , today = fromCalendarDate 2017 Mar 2
                            , entries =
                                [ DateEntries (fromCalendarDate 2017 Feb 28)
                                    [ Entry 2.5 123, Entry 7 234 ]
                                , DateEntries (fromCalendarDate 2017 Mar 1)
                                    [ Entry 5 123, Entry 2.5 234 ]
                                , DateEntries (fromCalendarDate 2017 Mar 2)
                                    [ Entry 2.5 123, Entry 5 234 ]
                                , DateEntries (fromCalendarDate 2017 Apr 1)
                                    [ Entry 2.5 123, Entry 7 234 ]
                                ]
                        }
                in
                hourBalanceOfCurrentMonth model
                    |> Expect.equal 0
        , test "day has only special task entries" <|
            \() ->
                let
                    specialTasks =
                        { kiky = [ { id = 123 } ]
                        , ignore = [ { id = 234 } ]
                        }

                    dateEntries =
                        DateEntries (fromCalendarDate 2017 Feb 28)
                            [ Entry 2.5 123, Entry 7 234 ]
                in
                dayHasOnlySpecialTasks dateEntries specialTasks
                    |> Expect.true "Expected the day to have only special task entries."
        , test "day has no task entries" <|
            \() ->
                let
                    specialTasks =
                        { kiky = [ { id = 123 } ]
                        , ignore = [ { id = 234 } ]
                        }

                    dateEntries =
                        DateEntries (fromCalendarDate 2017 Feb 28)
                            []
                in
                dayHasOnlySpecialTasks dateEntries specialTasks
                    |> Expect.false "Expected the day to have no special task entries."
        , test "day has special and normal task entries" <|
            \() ->
                let
                    specialTasks =
                        { kiky = [ { id = 123 } ]
                        , ignore = [ { id = 234 } ]
                        }

                    dateEntries =
                        DateEntries (fromCalendarDate 2017 Feb 28)
                            [ Entry 2.5 123, Entry 2.5 234, Entry 2 1000 ]
                in
                dayHasOnlySpecialTasks dateEntries specialTasks
                    |> Expect.false "Expected the day to have also normal task entries."
        , describe "dateInCurrentMonth"
            [ test "start of month" <|
                \_ ->
                    dateInCurrentMonth (fromCalendarDate 2017 Mar 1) (fromCalendarDate 2017 Mar 1)
                        |> Expect.true "First of March should be within March"
            , test "end of month" <|
                \_ ->
                    dateInCurrentMonth (fromCalendarDate 2017 Mar 31) (fromCalendarDate 2017 Mar 1)
                        |> Expect.true "Last of March should be within March"
            , test "not in month" <|
                \_ ->
                    dateInCurrentMonth (fromCalendarDate 2017 Jun 31) (fromCalendarDate 2017 Mar 1)
                        |> Expect.false "Last of June should not be within March"
            ]
        , describe "totalHoursForMonth"
            [
                test "March should have 15 hours" <|
                \_ ->
                    let
                        model =
                            { initialModel
                                | currentDate = fromCalendarDate 2017 Mar 5
                                , today = fromCalendarDate 2017 Mar 2
                                , entries =
                                    [ DateEntries (fromCalendarDate 2017 Mar 1)
                                        [ Entry 5 123, Entry 2.5 234 ]
                                    , DateEntries (fromCalendarDate 2017 Mar 2)
                                        [ Entry 2.5 123, Entry 5 234 ]
                                    ]
                            }
                    in
                    totalHoursForMonth model
                        |> Expect.equal 15
            ]
        ]


initialModel : Model
initialModel =
    { httpError = Ok ()
    , loading = True
    , today = fromPosix utc (millisToPosix 0)
    , currentDate = fromPosix utc (millisToPosix 0)
    , entries = []
    , totalHours = Nothing
    , kikyHours = Nothing
    , hourBalanceOfCurrentMonth = Nothing
    , user = { firstName = "", lastName = "", previousBalance = 0 }
    , holidays = []
    , specialTasks =
        { ignore = []
        , kiky = []
        }
    , previousBalanceString = ""
    , previousBalance = 0
    , mdc = Material.defaultModel
    , showDialog = False
    }
