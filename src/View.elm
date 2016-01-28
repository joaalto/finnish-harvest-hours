module View where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import Model exposing (..)
import Update exposing (..)

view : Address Action -> Model -> Html
view address model =
    div [] []
