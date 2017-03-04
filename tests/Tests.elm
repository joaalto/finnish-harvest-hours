module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import FormattingTest


all : Test
all =
    describe
        "Test Suite"
        [ describe "Unit tests"
            [ FormattingTest.all ]
        ]
