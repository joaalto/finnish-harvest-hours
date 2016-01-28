module Update where

import Model exposing (Model)
import Effects exposing (Effects)

type Action =
    GetDayEntries

update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        GetDayEntries -> (model, Effects.none)
