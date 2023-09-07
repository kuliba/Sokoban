//
//  DecodableLanding.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

struct DecodableLanding: Decodable {
    
    let data: Data
    
    struct Data: Decodable {
        
        let header: [DataView]
        let main: [DataView]
        let footer: [DataView]
        let details: [Detail]
        let serial: String
    }
}

extension DecodableLanding.Data {
    
    enum LandingComponentsType: String, Decodable, Equatable {
        
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
        case multiMarkersText = "MULTI_MARKERS_TEXT"
        case multiTextsWithIconsHorizontal = "MULTI_TEXTS_WITH_ICONS_HORIZONTAL"
    }

    enum DataView: Decodable, Equatable {
        
        case list(List)
        case multi(Multi)

        enum List: Decodable, Equatable  {
            case listHorizontalRectangleImage(ListHorizontalRectangleImage)
            case listHorizontalRoundImage(ListHorizontalRoundImage)
            case listVerticalRoundImage(ListVerticalRoundImage)
        }
        
        enum Multi: Decodable, Equatable  {
            
            case multiLineHeader(MultiLineHeader)
            case multiMarkersText(MultiMarkersText)
            case multiText(MultiText)
            case multiTextsWithIconsHorizontalArray([MultiTextsWithIconsHorizontal])
        }
        
        case noValid(String)
        case iconWithTwoTextLines(IconWithTwoTextLines)
        case pageTitle(PageTitle)
        case textsWithIconHorizontal(TextsWithIconHorizontal)
        
        init(from decoder: Decoder) throws {
            
            enum CodingKeys: CodingKey {
                case type
                case data
            }

            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try container.decode(LandingComponentsType.self, forKey: .type)
            
            switch type {
                
            case .iconWithTwoTextLines:
                let data = try container.decode(IconWithTwoTextLines.self, forKey: .data)
                self = .iconWithTwoTextLines(data)
                
            case .listHorizontalRectangleImage:
                let data = try container.decode(ListHorizontalRectangleImage.self, forKey: .data)
                self = .list(.listHorizontalRectangleImage(data))
                
            case .listHorizontalRoundImage:
                let data = try container.decode(ListHorizontalRoundImage.self, forKey: .data)
                self = .list(.listHorizontalRoundImage(data))
            
            case .listVerticalRoundImage:
                let data = try container.decode(ListVerticalRoundImage.self, forKey: .data)
                self = .list(.listVerticalRoundImage(data))
                
            case .multiLineHeader:
                let data = try container.decode(MultiLineHeader.self, forKey: .data)
                self = .multi(.multiLineHeader(data))
            
            case .multiMarkersText:
                let data = try container.decode(MultiMarkersText.self, forKey: .data)
                self = .multi(.multiMarkersText(data))
                
            case .multiText:
                let data = try container.decode(MultiText.self, forKey: .data)
                self = .multi(.multiText(data))
                
            case .multiTextsWithIconsHorizontal:
                let data = try container.decode([MultiTextsWithIconsHorizontal].self, forKey: .data)
                self = .multi(.multiTextsWithIconsHorizontalArray(data))
            
            case .pageTitle:
                let data = try container.decode(PageTitle.self, forKey: .data)
                self = .pageTitle(data)
            
            case .textWithIconHorizontal:
                let data = try container.decode(TextsWithIconHorizontal.self, forKey: .data)
                self = .textsWithIconHorizontal(data)
                
            default:
                // не смогли распарсить - нет такого type
                self = .noValid(type.rawValue)
                
                /*
                 case .verticalSpacing:
                 <#code#>
                 case .multiButtons:
                 <#code#>
                 case .listDropDownTexts:
                 <#code#>
                 case .image:
                 <#code#>
                 */
            }
        }
    }
}
