//
//  LandingComponentsType.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public enum LandingComponentsType: String, Equatable {
        
        case listHorizontalRoundImage = "LIST_HORIZONTAL_ROUND_IMAGE"
        case multiLineHeader = "MULTI_LINE_HEADER"
        case iconWithTwoTextLines = "ICON_WITH_TWO_TEXT_LINES"
        case verticalSpacing = "VERTICAL_SPACING"
        case textWithIconHorizontal = "TEXTS_WITH_ICON_HORIZONTAL"
        case listHorizontalRectangleImage = "LIST_HORIZONTAL_RECTANGLE_IMAGE"
        case listVerticalRoundImage = "LIST_VERTICAL_ROUND_IMAGE"
        case multiButtons = "MULTI_BUTTONS"
        case listDropDownTexts = "LIST_DROP_DOWN_TEXTS"
        case multiText = "MULTI_TEXT"
        case pageTitle = "PAGE_TITLE"
        case image = "IMAGE"
        case imageSvg = "IMAGE_SVG"
        case multiMarkersText = "MULTI_MARKERS_TEXT"
        case multiTextsWithIconsHorizontal = "MULTI_TEXTS_WITH_ICONS_HORIZONTAL"
        case multiTypeButtons = "MULTI_TYPE_BUTTONS"
        case unknow
    }
}
