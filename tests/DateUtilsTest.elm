module DateUtilsTest exposing (all)

import Test exposing (..)
import Expect
import Date exposing (Month(..), Date)
import Date.Extra.Create exposing (dateFromFields)
import Material
import Model exposing (..)
import DateUtils exposing (..)

all : Test
all =
    describe "Date utils"
        [ test "only entries within current month are added up" <|
            \() ->
                let
                    model =
                        { initialModel
                            | currentDate = (dateFromFields 2017 Mar 5 0 1 0 0)
                            , today = (dateFromFields 2017 Mar 2 0 1 0 0)
                            , entries =
                                [ DateEntries (dateFromFields 2017 Feb 28 22 59 0 0)
                                    [ Entry 2.5 123, Entry 7 234 ]
                                , DateEntries (dateFromFields 2017 Mar 1 22 59 0 0)
                                    [ Entry 5 123, Entry 2.5 234 ]
                                , DateEntries (dateFromFields 2017 Mar 2 22 59 0 0)
                                    [ Entry 2.5 123, Entry 5 234 ]
                                , DateEntries (dateFromFields 2017 Apr 1 0 0 0 0)
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
                        DateEntries (dateFromFields 2017 Feb 28 0 0 0 0)
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
                        DateEntries (dateFromFields 2017 Feb 28 0 0 0 0)
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
                        DateEntries (dateFromFields 2017 Feb 28 0 0 0 0)
                            [ Entry 2.5 123, Entry 2.5 234, Entry 2 1000 ]
                in
                    dayHasOnlySpecialTasks dateEntries specialTasks
                        |> Expect.false "Expected the day to have also normal task entries."
        , test "can use variantPeriods" <|
            \() ->
                let
                    -- Variant period start and end must be at the start and end of the date respectively.
                   variantPeriods =
                       [ VariantPeriod
                           (dateFromFields 2017 Mar 2 0 0 0 0)
                           (Just (dateFromFields 2017 Mar 3 23 59 0 0))
                           5
                       , VariantPeriod
                           (dateFromFields 2017 Mar 8 0 0 0 0)
                           (Just (dateFromFields 2017 Mar 8 23 59 0 0))
                           6
                       ]

                   model =
                       { initialModel
                           | currentDate = (dateFromFields 2017 Mar 8 22 59 0 0)
                           , today = (dateFromFields 2017 Mar 8 22 59 0 0)
                           , entries =
                               [ DateEntries (dateFromFields 2017 Mar 2 22 59 0 0)
                                   [ Entry 2.5 123, Entry 2.5 234 ]
                               , DateEntries (dateFromFields 2017 Mar 3 22 59 0 0)
                                   [ Entry 7.5 123 ]
                               -- 4th and 5th are the weekend
                               -- 6th intentionally left empty, implicit 0 h
                               , DateEntries (dateFromFields 2017 Mar 7 22 59 0 0)
                                   [ Entry 6 123 ]
                               , DateEntries (dateFromFields 2017 Mar 8 22 59 0 0)
                                   [ Entry 5.5 123 ]
                               ]
                           , user = replaceVariantPeriods variantPeriods initialModel
                       }
                in
                    calculateHourBalance model
                        |> Expect.equal { normalHours = -7, kikyHours = 0 }
        , test "computes correct total balance for a variant period without end date" <|
            \() ->
                let
                    variantPeriods =
                        [ VariantPeriod
                            (dateFromFields 2017 Mar 2 0 0 0 0)
                            Nothing
                            7
                        ]
                    model =
                        { initialModel
                            | currentDate = (dateFromFields 2017 Mar 3 22 59 0 0)
                            , today = (dateFromFields 2017 Mar 3 22 59 0 0)
                            , entries =
                                [ DateEntries (dateFromFields 2017 Mar 2 22 59 0 0)
                                    [ Entry 2.5 123, Entry 2.5 234 ]
                                , DateEntries (dateFromFields 2017 Mar 3 22 59 0 0)
                                    [ Entry 7 123 ]
                                ]
                            , user = replaceVariantPeriods variantPeriods initialModel
                        }
                in
                    calculateHourBalance model
                        |> Expect.equal { normalHours = -2, kikyHours = 0 }

        , test "computes correct monthly balance for first month of employment" <|
            \() ->
                let
                    model =
                        { initialModel
                            | currentDate = (dateFromFields 2017 Mar 7 20 1 0 0)
                            , today = (dateFromFields 2017 Mar 7 20 1 0 0)
                            , entries =
                                [ DateEntries (dateFromFields 2017 Mar 6 10 59 0 0)
                                    [ Entry 5 123, Entry 2.5 234 ]
                                , DateEntries (dateFromFields 2017 Mar 7 10 59 0 0)
                                    [ Entry 2.5 123, Entry 5 234 ]
                                ]
                        }
                in
                    hourBalanceOfCurrentMonth model
                        |> Expect.equal 0
        , test "computes correct monthly balance for variant periods starting or ending during month" <|
            \() ->
                let
                     -- Variant period start and end must be at the start and end of the date respectively.
                    variantPeriods =
                        [ VariantPeriod
                            (dateFromFields 2017 Mar 2 23 59 0 0)
                            (Just (dateFromFields 2017 Mar 3 23 59 0 0))
                            5
                        , VariantPeriod
                            (dateFromFields 2017 Mar 8 0 0 0 0)
                            Nothing
                            6
                        ]

                    model =
                        { initialModel
                            | currentDate = (dateFromFields 2017 Mar 8 22 59 0 0)
                            , today = (dateFromFields 2017 Mar 8 22 59 0 0)
                            , entries =
                                [ DateEntries (dateFromFields 2017 Mar 2 22 59 0 0)
                                    [ Entry 2.5 123, Entry 2.5 234 ]
                                , DateEntries (dateFromFields 2017 Mar 3 22 59 0 0)
                                    [ Entry 7.5 123 ]
                                -- 4th and 5th are the weekend
                                -- 6th intentionally left empty, implicit 0 h
                                , DateEntries (dateFromFields 2017 Mar 7 22 59 0 0)
                                    [ Entry 6 123 ]
                                , DateEntries (dateFromFields 2017 Mar 8 22 59 0 0)
                                    [ Entry 5.5 123 ]
                                ]
                            , user = replaceVariantPeriods variantPeriods initialModel
                        }
                in
                    hourBalanceOfCurrentMonth model
                        |> Expect.equal -7
        ]


initialModel : Model
initialModel =
    { httpError = Ok ()
    , loading = True
    , today = Date.fromTime 0
    , currentDate = Date.fromTime 0
    , entries = []
    , totalHours = Nothing
    , kikyHours = Nothing
    , hourBalanceOfCurrentMonth = Nothing
    , user = { firstName = "", lastName = "", previousBalance = 0, variantPeriods = [] }
    , holidays = []
    , specialTasks =
        { ignore = []
        , kiky = []
        }
    , previousBalanceString = ""
    , previousBalance = 0
    , mdl = Material.model
    }

replaceVariantPeriods : List VariantPeriod -> Model -> User
replaceVariantPeriods newVariantPeriods model =
     let
        oldUser = model.user
     in
        { oldUser | variantPeriods = newVariantPeriods}
