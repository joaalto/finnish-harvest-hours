module Update where

import Model exposing (Model)
import Effects exposing (Effects)

type Action
    = Login
    | GetDayEntries

update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        Login -> noFx model
        GetDayEntries -> noFx model

noFx : Model -> (Model, Effects Action)
noFx model =
    (model, Effects.none)
