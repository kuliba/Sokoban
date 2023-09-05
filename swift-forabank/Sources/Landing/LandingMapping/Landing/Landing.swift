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
    public let footer: [DataView?]
    public let details: [Detail]
    public let serial: String
    
    public init(
        header: [DataView],
        main: [DataView],
        footer: [DataView?],
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
        
        case iconWithTwoTextLines(IconWithTwoTextLines)
        case listHorizontalRoundImage(ListHorizontalRoundImage)
        case multiLineHeader(MultiLineHeader)
        case empty
        case pageTitle(PageTitle)
        case multiTextsWithIconsHorizontalArray(MuiltiTextsWithIconsHorizontal)
        case textsWithIconHorizontal(TextsWithIconHorizontal)
        case listHorizontalRectangleImage(ListHorizontalRectangleImage)
    }
}
