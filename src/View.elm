module View where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import Model exposing (..)
import Update exposing (..)

view : Address Action -> Model -> Html
view address model =
    case model.httpError of
        Err err ->
            div
                [ style [ ("color", "red" ) ]]
                [ text (toString err) ]
        Ok _ ->
            div
                []
                []
