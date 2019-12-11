module Formatting exposing (floatToHoursAndMins, dateToString)

import Round as R
import Date exposing (Date)
import Date.Extra.Config.Config_fi_fi exposing (config)
import Date.Extra.Format as Format exposing (format)


{-| Take a float and return a string with hours and minutes, eg.
    4.25 -> "4:15"
-}
floatToHoursAndMins : Maybe Float -> String
floatToHoursAndMins hours =
    case hours of
        Nothing ->
            ""

        Just val ->
            let
                hoursAndDecimals =
                    R.round 2 val |> String.split "."
            in
                case hoursAndDecimals of
                    [ hourString, decimalString ] ->
                        let
                            minString =
                                Result.withDefault 0 (String.toFloat decimalString)
                                    * 0.6
                                    |> R.round 0
                                    |> String.padRight 2 '0'
                        in
                            String.join ":" [ hourString, minString ]

                    _ ->
                        ""

{-| Take a Date and return a string with day, month and year;
    aDate -> "31.01.2019"
-}
dateToString : Maybe Date -> String
dateToString date =
    case date of
        Nothing -> "∞"

        Just d -> format config "%d.%m.%Y" d
