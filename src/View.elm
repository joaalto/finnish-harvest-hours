module View exposing (..)

import Material.Dialog as Dialog
import Material.Button as Button
import Material.Options as Options
import List
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import DateUtils exposing (..)
import Calendar exposing (monthView)
import Date exposing (..)
import String
import Model exposing (..)
import Update exposing (..)
import Formatting exposing (floatToHoursAndMins, dateToString)


view : Model -> Html Msg
view model =
    case model.httpError of
        Err err ->
            div [ style [ ( "color", "red" ) ] ]
                [ text (toString err) ]

        Ok _ ->
            div [ class "main" ]
                [ div []
                    [ dialog model ]
                , div [ class "header" ]
                    [ span [ class "name" ]
                        [ text (String.join " " [ model.user.firstName, model.user.lastName ]) ]
                    , Button.render Mdl
                        [ 1 ]
                        model.mdl
                        [ Dialog.openOn "click"
                        , Options.cs "calendar-button"
                        ]
                        [ i [ class "fa settings fa-calendar" ] [] ]
                    , text (String.join " " [ "Total hour balance:", (floatToHoursAndMins model.totalHours) ])
                    ]
                , navigationPane model
                , calendarTable model
                ]


dialog : Model -> Html Msg
dialog model =
    Dialog.view []
        [ Dialog.title [] [ h3 [] [ text "Set base hour saldo" ] ]
        , Dialog.content []
            [ input
                [ class "balance-input"
                , onInput UpdatePreviousBalance
                , onBlur (SavePreviousBalance model.previousBalance)
                , value model.previousBalanceString
                ]
                []
            , h4 [ ] [ text "Non-standard working periods" ]
            , p [] [
                text "Contact your Saldot administrator to configure parental leaves, part-time work and other longer duration arrangements."
                , variantTable model
                ]
            ]
        , Dialog.actions []
            [ Button.render Mdl
                [ 0 ]
                model.mdl
                [ Dialog.closeOn "click"
                , Options.cs "close-button"
                ]
                [ text "Close" ]
            ]
        ]


navigationPane : Model -> Html Msg
navigationPane model =
    div [ class "navigation" ]
        [ div []
            [ button [ onClick PreviousMonth, class "nav-button float-left" ]
                [ i [ class "fa fa-arrow-left" ] [] ]
            ]
        , div []
            [ button [ onClick NextMonth, class "nav-button float-left" ]
                [ i [ class "fa fa-arrow-right" ] [] ]
            ]
        , div [ class "monthly-balance float-left" ]
            [ text
                (String.join " "
                    [ "Monthly hour balance: "
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

variantRow : VariantPeriod -> Html Msg
variantRow variant =
    tr []
        [ td [] [ text (dateToString (Just variant.start)) ]
        , td [] [ text (dateToString variant.end) ]
        , td [] [ text (toString variant.dailyHours) ]
        ]

variantTable : Model -> Html Msg
variantTable model =
    if (List.length model.user.variantPeriods) > 0 then
        div [ class "variant-table" ] [
            table [  ]
                [ thead []
                    [ th [] [ text "Start" ]
                    , th [] [ text "End" ]
                    , th [] [ text "Hours / day" ]
                    ]
                , tbody []
                    (List.map variantRow model.user.variantPeriods)
                ]
        ]
    else
        span [] []
