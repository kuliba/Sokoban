//
//  CodableLanding+ext.swift
//
//
//  Created by Andryusina Nataly on 10.06.2024.
//

import Foundation

extension CodableLanding {
    
    public enum DataView: Equatable, Codable {
        
        case blockHorizontalRectangular(BlockHorizontalRectangular)
        case iconWithTwoTextLines(IconWithTwoTextLines)
        case image(ImageBlock)
        case imageSvg(ImageSvg)
        case list(List)
        case multi(Multi)
        case pageTitle(PageTitle)
        case textsWithIconHorizontal(TextsWithIconHorizontal)
        case verticalSpacing(VerticalSpacing)
    }
}

public extension CodableLanding {
    
    enum List: Equatable, Codable {
        
        case dropDownTexts(DropDownTexts)
        case horizontalRectangleImage(HorizontalRectangleImage)
        case horizontalRectangleLimits(HorizontalRectangleLimits)
        case horizontalRoundImage(HorizontalRoundImage)
        case verticalRoundImage(VerticalRoundImage)
    }
    
    enum Multi: Equatable, Codable {

        case buttons(Buttons)
        case lineHeader(LineHeader)
        case markersText(MarkersText)
        case text(Text)
        case textsWithIconsHorizontalArray(TextsWithIconsHorizontal)
        case typeButtons(TypeButtons)
    }
}
