module View exposing (calendarTable, dayCellClass, dialog, hourString, navigationPane, roundHours, spinnerClass, view, weekRow)

import Calendar exposing (monthView)
import Date exposing (..)
import DateUtils exposing (..)
import Formatting exposing (floatToHoursAndMins)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List
import Material
import Material.Button as Button
import Material.Dialog as Dialog
import Material.Options as Options
import Model exposing (..)
import Round
import String
import Update exposing (..)


view : Model -> Html Msg
view model =
    case model.httpError of
        Err err ->
            div [ style "color" "red" ]
                [ text (Debug.toString err) ]

        Ok _ ->
            Options.styled div
                [ Options.cs "main"
                ]
                [ div []
                    [ dialog "dialog-options" model ]
                , div [ class "header" ]
                    [ span [ class "name" ]
                        [ text (String.join " " [ model.user.firstName, model.user.lastName ]) ]
                    , Button.view Mdc
                        "dialog-options-show"
                        model.mdc
                        [ Button.unelevated
                        , Button.onClick ShowDialog
                        , Options.cs "calendar-button"
                        ]
                        [ i [ class "fa settings fa-calendar" ] [] ]
                    , text (String.join " " [ "Tuntisaldo:", floatToHoursAndMins model.totalHours ])
                    ]
                , div [ class "kiky" ]
                    [ text (String.join " " [ "Kikytunnit:", floatToHoursAndMins model.kikyHours ]) ]
                , navigationPane model
                , calendarTable model
                ]


roundHours : Int -> Maybe Float -> String
roundHours decimals hours =
    case hours of
        Nothing ->
            ""

        Just val ->
            String.join " " [ Round.round decimals val, "h" ]


dialog : Material.Index -> Model -> Html Msg
dialog index model =
    Dialog.view Mdc
        index
        model.mdc
        [ Dialog.open |> Options.when model.showDialog
        , Dialog.onClose Cancel
        ]
        [ Dialog.surface []
            [ Dialog.header []
                [ Options.styled Html.h3
                    [ Dialog.title
                    ]
                    [ text "Aseta vanha saldo"
                    ]
                ]
            , Dialog.body []
                [ input
                    [ class "balance-input"
                    , onInput UpdatePreviousBalance
                    , onBlur (SavePreviousBalance model.previousBalance)
                    , value model.previousBalanceString
                    ]
                    []
                ]
            , Dialog.footer []
                [ Button.view Mdc
                    "dialog-close-dialog"
                    model.mdc
                    [ Dialog.cancel
                    , Button.unelevated
                    , Options.cs "close-button"
                    , Options.onClick Cancel
                    ]
                    [ text "Sulje" ]
                ]
            ]
        ]


navigationPane : Model -> Html Msg
navigationPane model =
    div [ class "navigation" ]
        [ div []
            [ Button.view Mdc
                "button-previous-month"
                model.mdc
                [ Button.unelevated
                , Button.dense
                , Options.onClick PreviousMonth
                , Options.cs "nav-button float-left"
                ]
                [ i [ class "fa fa-arrow-left" ] [] ]
            ]
        , div []
            [ Button.view Mdc
                "button-next-month"
                model.mdc
                [ Button.unelevated
                , Button.dense
                , Options.onClick NextMonth
                , Options.cs "nav-button float-left"
                ]
                [ i [ class "fa fa-arrow-right" ] [] ]
            ]
        , div [ class "monthly-balance float-left" ]
            [ text
                (String.join " "
                    [ "Kuukauden tuntisaldo: "
                    , floatToHoursAndMins model.hourBalanceOfCurrentMonth
                    ]
                )
            ]
        , div [ class "spinner" ] [ i [ class (spinnerClass model) ] [] ]
        ]


spinnerClass : Model -> String
spinnerClass model =
    if model.loading then
        "fa fa-spinner fa-pulse spinner"

    else
        ""


calendarTable : Model -> Html Msg
calendarTable model =
    table [ class "month-view-table" ]
        [ thead []
            [ tr []
                []
            ]
        , tbody []
            (List.map (\week -> weekRow model week)
                (monthView model)
            )
        ]


weekRow : Model -> List DateEntries -> Html Msg
weekRow model dateList =
    tr []
        (List.map
            (\dateEntries ->
                td [ class (dayCellClass model dateEntries) ]
                    [ div [] [ text (dateFormat dateEntries.date) ]
                    , div [ class "hours" ]
                        [ text (hourString (.normalHours (calculateDailyHours dateEntries model)))
                        ]
                    ]
            )
            dateList
        )


hourString : Float -> String
hourString hours =
    if hours == 0 then
        ""

    else
        floatToHoursAndMins (Just hours)


dayCellClass : Model -> DateEntries -> String
dayCellClass model dateEntries =
    if not (isWorkDay dateEntries.date model.holidays) then
        "day-off"

    else if dayHasOnlySpecialTasks dateEntries model.specialTasks then
        "special-day"

    else if month dateEntries.date == month model.currentDate then
        "current-month"

    else
        "other-month"
