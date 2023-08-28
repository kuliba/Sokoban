//
//  LandingComponentsType.swift
//  
//
//  Created by Dmitry Martynov on 19.07.2023.
//

import Foundation

public enum LandingComponentsType: String, Decodable {
    
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
    case multiMarkersText = "MULTI_MARKERS_TEXT" //TODO:
    case multiTextsWithIconsHorizontal = "MULTI_TEXTS_WITH_ICONS_HORIZONTAL" //TODO: 
}

public enum LandingComponentsTypeWithModel: Equatable {
    
    case listHorizontalRoundImage(ListHorizontalRoundImageModel)
    case multiLineHeader(MultiLineHeaderModel)
    case iconWithTwoTextLines(IconWithTwoTextLinesModel)
    case verticalSpacing(VerticalSpacingModel)
    case textWithIconHorizontal(TextWithIconHorizontalModel)
    case listHorizontalRectangleImage(ListHorizontalRectangleImageModel)
    case listVerticalRoundImage(ListVerticalRoundImageModel)
    case multiButtons(MultiButtonsModel)
    case listDropDownTexts(ListDropDownTextsModel)
    case multiText(MultiTextModel)
    case pageTitle(PageTitleModel)
    case image(ImageModel)
}
