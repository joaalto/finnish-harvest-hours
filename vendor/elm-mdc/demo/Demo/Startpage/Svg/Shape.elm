module Demo.Startpage.Svg.Shape exposing (view)

import Html exposing (Html)
import Svg exposing (defs, desc, feColorMatrix, feGaussianBlur, feMerge, feMergeNode, feOffset, filter, g, mask, path, polygon, rect, svg, text, title, use)
import Svg.Attributes exposing (d, dx, dy, fill, fillOpacity, fillRule, filterUnits, height, id, in_, points, result, stdDeviation, stroke, strokeWidth, transform, type_, values, version, viewBox, width, x, xlinkHref, y)


view : Html msg
view =
    svg [ viewBox "0 0 180 180", version "1.1" ]
        [ title []
            [ text "shape_180px" ]
        , desc []
            [ text "Created with Sketch." ]
        , defs []
            [ polygon [ id "__1ACwhWP__path-1", points "0 0 180 0 180 180 0 180" ]
                []
            , path [ d "M16,0 L344,0 C352.836556,-1.623249e-15 360,7.163444 360,16 L360,254 L0,254 L0,16 C-1.082166e-15,7.163444 7.163444,1.623249e-15 16,0 Z", id "__1ACwhWP__path-3" ]
                []
            , filter [ x "-4.6%", y "-4.1%", width "109.2%", height "113.0%", filterUnits "objectBoundingBox", id "__1ACwhWP__filter-5" ]
                [ feOffset [ dx "0", dy "1", in_ "SourceAlpha", result "shadowOffsetOuter1" ]
                    []
                , feGaussianBlur [ stdDeviation "2.5", in_ "shadowOffsetOuter1", result "shadowBlurOuter1" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0", type_ "matrix", in_ "shadowBlurOuter1", result "shadowMatrixOuter1" ]
                    []
                , feOffset [ dx "0", dy "3", in_ "SourceAlpha", result "shadowOffsetOuter2" ]
                    []
                , feGaussianBlur [ stdDeviation "2", in_ "shadowOffsetOuter2", result "shadowBlurOuter2" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.12 0", type_ "matrix", in_ "shadowBlurOuter2", result "shadowMatrixOuter2" ]
                    []
                , feOffset [ dx "0", dy "2", in_ "SourceAlpha", result "shadowOffsetOuter3" ]
                    []
                , feGaussianBlur [ stdDeviation "2", in_ "shadowOffsetOuter3", result "shadowBlurOuter3" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.14 0", type_ "matrix", in_ "shadowBlurOuter3", result "shadowMatrixOuter3" ]
                    []
                , feMerge []
                    [ feMergeNode [ in_ "shadowMatrixOuter1" ]
                        []
                    , feMergeNode [ in_ "shadowMatrixOuter2" ]
                        []
                    , feMergeNode [ in_ "shadowMatrixOuter3" ]
                        []
                    ]
                ]
            , polygon [ id "__1ACwhWP__path-6", points "99.1888168 53 126 79.8111832 126 180 0 180 0 53" ]
                []
            , filter [ x "-13.1%", y "-8.3%", width "126.2%", height "126.0%", filterUnits "objectBoundingBox", id "__1ACwhWP__filter-8" ]
                [ feOffset [ dx "0", dy "1", in_ "SourceAlpha", result "shadowOffsetOuter1" ]
                    []
                , feGaussianBlur [ stdDeviation "2.5", in_ "shadowOffsetOuter1", result "shadowBlurOuter1" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0", type_ "matrix", in_ "shadowBlurOuter1", result "shadowMatrixOuter1" ]
                    []
                , feOffset [ dx "0", dy "3", in_ "SourceAlpha", result "shadowOffsetOuter2" ]
                    []
                , feGaussianBlur [ stdDeviation "2", in_ "shadowOffsetOuter2", result "shadowBlurOuter2" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.12 0", type_ "matrix", in_ "shadowBlurOuter2", result "shadowMatrixOuter2" ]
                    []
                , feOffset [ dx "0", dy "2", in_ "SourceAlpha", result "shadowOffsetOuter3" ]
                    []
                , feGaussianBlur [ stdDeviation "2", in_ "shadowOffsetOuter3", result "shadowBlurOuter3" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.14 0", type_ "matrix", in_ "shadowBlurOuter3", result "shadowMatrixOuter3" ]
                    []
                , feMerge []
                    [ feMergeNode [ in_ "shadowMatrixOuter1" ]
                        []
                    , feMergeNode [ in_ "shadowMatrixOuter2" ]
                        []
                    , feMergeNode [ in_ "shadowMatrixOuter3" ]
                        []
                    ]
                ]
            , polygon [ id "__1ACwhWP__path-9", points "0 87 94 87 94 180 0 180" ]
                []
            , filter [ x "-17.6%", y "-11.3%", width "135.1%", height "135.5%", filterUnits "objectBoundingBox", id "__1ACwhWP__filter-11" ]
                [ feOffset [ dx "0", dy "1", in_ "SourceAlpha", result "shadowOffsetOuter1" ]
                    []
                , feGaussianBlur [ stdDeviation "2.5", in_ "shadowOffsetOuter1", result "shadowBlurOuter1" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0", type_ "matrix", in_ "shadowBlurOuter1", result "shadowMatrixOuter1" ]
                    []
                , feOffset [ dx "0", dy "3", in_ "SourceAlpha", result "shadowOffsetOuter2" ]
                    []
                , feGaussianBlur [ stdDeviation "2", in_ "shadowOffsetOuter2", result "shadowBlurOuter2" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.12 0", type_ "matrix", in_ "shadowBlurOuter2", result "shadowMatrixOuter2" ]
                    []
                , feOffset [ dx "0", dy "2", in_ "SourceAlpha", result "shadowOffsetOuter3" ]
                    []
                , feGaussianBlur [ stdDeviation "2", in_ "shadowOffsetOuter3", result "shadowBlurOuter3" ]
                    []
                , feColorMatrix [ values "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.14 0", type_ "matrix", in_ "shadowBlurOuter3", result "shadowMatrixOuter3" ]
                    []
                , feMerge []
                    [ feMergeNode [ in_ "shadowMatrixOuter1" ]
                        []
                    , feMergeNode [ in_ "shadowMatrixOuter2" ]
                        []
                    , feMergeNode [ in_ "shadowMatrixOuter3" ]
                        []
                    ]
                ]
            ]
        , g [ id "__1ACwhWP__shape_180px", stroke "none", strokeWidth "1", fill "none", fillRule "evenodd" ]
            [ g [ id "__1ACwhWP__Front-Layer-+-Combined-Shape-+-Surface-Mask" ]
                [ mask [ id "__1ACwhWP__mask-2", fill "white" ]
                    [ use [ xlinkHref "#__1ACwhWP__path-1" ]
                        []
                    ]
                , use [ id "__1ACwhWP__Mask", fill "#FAFAFA", xlinkHref "#__1ACwhWP__path-1" ]
                    []
                , g [ id "__1ACwhWP__Backdrop-/-Elements-/-Front-Layer", Svg.Attributes.mask "url(#__1ACwhWP__mask-2)" ]
                    [ g [ transform "translate(-204.000000, 23.000000)" ]
                        [ mask [ id "__1ACwhWP__mask-4", fill "white" ]
                            [ use [ xlinkHref "#__1ACwhWP__path-3" ]
                                []
                            ]
                        , g [ id "__1ACwhWP__Surface", stroke "none", fill "none" ]
                            [ use [ fill "black", fillOpacity "1", Svg.Attributes.filter "url(#__1ACwhWP__filter-5)", xlinkHref "#__1ACwhWP__path-3" ]
                                []
                            , use [ fill "#FAFAFA", fillRule "evenodd", xlinkHref "#__1ACwhWP__path-3" ]
                                []
                            ]
                        , g [ id "__1ACwhWP__?-/-Color-/-Surface-/-Main", stroke "none", fill "none", Svg.Attributes.mask "url(#__1ACwhWP__mask-4)", fillRule "evenodd" ]
                            [ g [ id "__1ACwhWP__?-/-Color-/-Surface-/-Base", fill "#FFFFFF" ]
                                [ rect [ id "__1ACwhWP__Rectangle-13", x "0", y "0", width "360", height "254" ]
                                    []
                                ]
                            ]
                        ]
                    ]
                , mask [ id "__1ACwhWP__mask-7", fill "white" ]
                    [ use [ xlinkHref "#__1ACwhWP__path-6" ]
                        []
                    ]
                , g [ id "__1ACwhWP__Combined-Shape" ]
                    [ use [ fill "black", fillOpacity "1", Svg.Attributes.filter "url(#__1ACwhWP__filter-8)", xlinkHref "#__1ACwhWP__path-6" ]
                        []
                    , use [ fill "#FFFFFF", fillRule "evenodd", xlinkHref "#__1ACwhWP__path-6" ]
                        []
                    ]
                , mask [ id "__1ACwhWP__mask-10", fill "white" ]
                    [ use [ xlinkHref "#__1ACwhWP__path-9" ]
                        []
                    ]
                , g [ id "__1ACwhWP__Surface" ]
                    [ use [ fill "black", fillOpacity "1", Svg.Attributes.filter "url(#__1ACwhWP__filter-11)", xlinkHref "#__1ACwhWP__path-9" ]
                        []
                    , use [ fill "#FFFFFF", fillRule "evenodd", xlinkHref "#__1ACwhWP__path-9" ]
                        []
                    ]
                ]
            ]
        ]
