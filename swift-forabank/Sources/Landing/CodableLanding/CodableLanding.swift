//
//  LandingCodable.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.09.2023.
//

import Foundation

public struct CodableLanding: Codable, Equatable {

    public let header: [DataView]
    public let main: [DataView]
    public let footer: [DataView]
    public let details: [Detail]
    public let serial: String?
    
    public init(header: [DataView], main: [DataView], footer: [DataView], details: [Detail], serial: String?) {
        self.header = header
        self.main = main
        self.footer = footer
        self.details = details
        self.serial = serial
    }
}

extension CodableLanding {
    
    public enum DataView: Equatable, Codable {
        
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
