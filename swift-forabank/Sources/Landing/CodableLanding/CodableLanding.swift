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
        
        case list(ListCodable)
        case multi(MultiCodable)
        
        public enum ListCodable: Equatable, Codable {
            case horizontalRectangleImage(ListHorizontalRectangleImage)
            case horizontalRoundImage(ListHorizontalRoundImage)
            case verticalRoundImage(ListVerticalRoundImage)
            case dropDownTexts(ListDropDownTexts)
        }
        
        public enum MultiCodable: Equatable, Codable {
            case lineHeader(MultiLineHeader)
            case markersText(MultiMarkersText)
            case text(MultiText)
            case textsWithIconsHorizontalArray(MuiltiTextsWithIconsHorizontal)
            case buttons(MultiButtons)
            case typeButtons(MultiTypeButtons)
        }
        
        case iconWithTwoTextLines(IconWithTwoTextLines)
        case pageTitle(PageTitle)
        case textsWithIconHorizontal(TextsWithIconHorizontal)
        case image(ImageBlock)
        case imageSvg(ImageSvg)
        case verticalSpacing(VerticalSpacing)
    }
}
