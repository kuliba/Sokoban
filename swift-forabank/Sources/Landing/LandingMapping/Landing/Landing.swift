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
    public let serial: String
    
    public init(
        header: [DataView],
        main: [DataView],
        footer: [DataView],
        details: [Detail],
        serial: String
    ) {
        self.header = header
        self.main = main
        self.footer = footer
        self.details = details
        self.serial = serial
    }
}

extension Landing {
    
    public enum DataView: Equatable {
        
        case list(List)
        case multi(Multi)
        
        public enum List: Equatable {
            case horizontalRectangleImage(ListHorizontalRectangleImage)
            case horizontalRoundImage(ListHorizontalRoundImage)
            case verticalRoundImage(ListVerticalRoundImage)
        }
        
        public enum Multi: Equatable {
            case lineHeader(MultiLineHeader)
            case markersText(MultiMarkersText)
            case text(MultiText)
            case textsWithIconsHorizontalArray(MuiltiTextsWithIconsHorizontal)
        }

        case iconWithTwoTextLines(IconWithTwoTextLines)
        case pageTitle(PageTitle)
        case textsWithIconHorizontal(TextsWithIconHorizontal)
    }
}
