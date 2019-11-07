module FormattingTest exposing (all)

import Test exposing (..)
import Expect
import Round exposing (round)
import Date exposing (Month(..), Date)
import Date.Extra.Create exposing (dateFromFields)
import Formatting exposing (floatToHoursAndMins, dateToString)


all : Test
all =
    describe "Formatting"
    [ describe "Hour formatting"
        [ test "Format Int to String with two decimals" <|
            \() ->
                Round.round 2 5
                    |> Expect.equal "5.00"
        , test "Format int to hours and minutes" <|
            \() ->
                floatToHoursAndMins (Just 4) |> Expect.equal "4:00"
        , test "Format 4.25" <|
            \() ->
                floatToHoursAndMins (Just 4.25) |> Expect.equal "4:15"
        , test "Format 0.333" <|
            \() ->
                floatToHoursAndMins (Just 0.333) |> Expect.equal "0:20"
        , test "Format 0.21" <|
            \() ->
                floatToHoursAndMins (Just 0.21) |> Expect.equal "0:13"
        ]
    , describe "Date formatting"
        [ test "Formats date to String" <|
            \() ->
                dateToString (Just (dateFromFields 2017 Mar 27 23 59 0 0)) |> Expect.equal "27.03.2017"
        , test "Formats nothing to infinity symbol" <|
            \() ->
                dateToString Nothing |> Expect.equal "∞"
        ]
    ]
