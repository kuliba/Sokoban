//
//  Landing.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

public struct Landing: Equatable {
    
    let header: [Header]
    let main: [DataView]
    let footer: [String]?
    let details: [Detail]
    let serial: String
    
    public init(
        header: [Header],
        main: [DataView],
        footer: [String]?,
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
        
        case multiTextsWithIconsHorizontalArray([MuiltiTextsWithIconsHorizontal])
        case textsWithIconHorizontal(TextsWithIconHorizontal)
    }
}
