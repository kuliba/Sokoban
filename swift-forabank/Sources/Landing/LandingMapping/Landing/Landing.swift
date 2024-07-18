//
//  Landing.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

public struct Landing: Equatable {
    
    public let header: [DataView]
    public let main: [DataView]
    public let footer: [DataView]
    public let details: [Detail]
    public let serial: String?
    public let statusCode: Int
    public let errorMessage: String?

    public init(header: [DataView], main: [DataView], footer: [DataView], details: [Detail], serial: String?, statusCode: Int, errorMessage: String?) {
        self.header = header
        self.main = main
        self.footer = footer
        self.details = details
        self.serial = serial
        self.statusCode = statusCode
        self.errorMessage = errorMessage
    }
}

extension Landing {
    
    public enum DataView: Equatable {
        
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

public extension Landing.DataView {
    
    enum List: Equatable {
        
        case dropDownTexts(DropDownTexts)
        case horizontalRectangleImage(HorizontalRectangleImage)
        case horizontalRectangleLimits(HorizontalRectangleLimits)
        case horizontalRoundImage(HorizontalRoundImage)
        case verticalRoundImage(VerticalRoundImage)
    }
    
    enum Multi: Equatable {
        
        case buttons(Buttons)
        case lineHeader(LineHeader)
        case markersText(MarkersText)
        case text(Text)
        case textsWithIconsHorizontalArray(TextsWithIconsHorizontal)
        case typeButtons(TypeButtons)
    }
}

public extension Landing {
    
    var horizontalRectangleLimits: Landing.DataView.List.HorizontalRectangleLimits? {
        
        for dataView in main {
            if case let .list(.horizontalRectangleLimits(limits)) = dataView {
                return limits
            }
        }
        return nil
    }
}
