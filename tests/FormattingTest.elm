module FormattingTest exposing (all)

import Test exposing (..)
import Expect
import Round exposing (round)
import Formatting exposing (floatToHoursAndMins)


all : Test
all =
    describe "Hour formatting"
        [ test "Format Int to String with to decimals" <|
            \() ->
                Round.round 2 5
                    |> Expect.equal "5.00"
        , test "Format int to hours and minutes" <|
            \() ->
                floatToHoursAndMins (Just 4) |> Expect.equal "4:00"
        , test "Format float to hours and minutes" <|
            \() ->
                floatToHoursAndMins (Just 4.25) |> Expect.equal "4:15"
        ]
