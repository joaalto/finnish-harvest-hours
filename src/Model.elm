module Model where

import Http

type alias Model =
    { httpError : Result Http.Error ()
    , hours : Int
    }
