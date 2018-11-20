port module Ports exposing (..)

import Time exposing (Time)


port currentTime : (Time -> msg) -> Sub msg
