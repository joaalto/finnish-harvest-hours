module FormattingTest exposing (all)

import Test exposing (..)
import Expect
import Round exposing (round)


all : Test
all =
    describe "Hour formatting"
        [ test "Format Int to String with to decimals" <|
            \() ->
                Round.round 2 5
                    |> Expect.equal "5.00"
        ]
