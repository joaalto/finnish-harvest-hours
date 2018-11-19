module CalendarTest exposing (suite)

import Date exposing (Unit(..), fromCalendarDate, fromPosix)
import Time exposing (millisToPosix, utc)
import Calendar exposing (..)
import Expect
import Material
import Model exposing (..)
import Test exposing (..)
import Time exposing (Month(..))



suite : Test
suite =
    describe "Calendar"
        [
            describe "dateRange"
                [
                     test "should include correct entries for specifed date range" <|
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
                            dateRange model (fromCalendarDate 2017 Mar 1) (fromCalendarDate 2017 Mar 3) []
                                |> Expect.equal [
                                    DateEntries (fromCalendarDate 2017 Mar 1)
                                        [ Entry 5 123, Entry 2.5 234 ]
                                    , DateEntries (fromCalendarDate 2017 Mar 2)
                                        [ Entry 2.5 123, Entry 5 234 ]
                                    , DateEntries (fromCalendarDate 2017 Mar 3)
                                        []
                                ]
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
