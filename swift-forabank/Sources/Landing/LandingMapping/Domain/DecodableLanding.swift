//
//  DecodableLanding.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

struct DecodableLanding: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: Data?
    
    struct Data: Decodable {
        
        let header: [DataView]?
        let main: [DataView]
        let footer: [DataView]?
        let details: [Detail]?
        let serial: String
    }
}

extension DecodableLanding.Data {
    
    enum LandingComponentsType: String, Decodable, Equatable {
        
        case blockHorizontalRectangular = "BLOCK_HORIZONTAL_RECTANGULAR"
        case iconWithTwoTextLines = "ICON_WITH_TWO_TEXT_LINES"
        case image = "IMAGE"
        case imageSvg = "IMAGE_SVG"
        case listDropDownTexts = "LIST_DROP_DOWN_TEXTS"
        case listHorizontalRectangleImage = "LIST_HORIZONTAL_RECTANGLE_IMAGE"
        case listHorizontalRectangleLimits = "LIST_HORIZONTAL_RECTANGLE_LIMITS"
        case listHorizontalRoundImage = "LIST_HORIZONTAL_ROUND_IMAGE"
        case listVerticalRoundImage = "LIST_VERTICAL_ROUND_IMAGE"
        case multiButtons = "MULTI_BUTTONS"
        case multiLineHeader = "MULTI_LINE_HEADER"
        case multiMarkersText = "MULTI_MARKERS_TEXT"
        case multiText = "MULTI_TEXT"
        case multiTextsWithIconsHorizontal = "MULTI_TEXTS_WITH_ICONS_HORIZONTAL"
        case multiTypeButtons = "MULTI_TYPE_BUTTONS"
        case pageTitle = "PAGE_TITLE"
        case textWithIconHorizontal = "TEXTS_WITH_ICON_HORIZONTAL"
        case verticalSpacing = "VERTICAL_SPACING"
    }

    // TODO: ListHorizontalRectangleImage -> List.Horizontal.RectangleImage
    enum DataView: Decodable, Equatable {
        
        case list(List)
        case multi(Multi)

        enum List: Decodable, Equatable  {
            case horizontalRectangleImage(ListHorizontalRectangleImage)
            case horizontalRoundImage(ListHorizontalRoundImage)
            case horizontalRectangleLimits(ListHorizontalRectangleLimits)
            case verticalRoundImage(ListVerticalRoundImage)
            case dropDownTexts(ListDropDownTexts)
        }
        
        enum Multi: Decodable, Equatable  {
            
            case lineHeader(MultiLineHeader)
            case markersText(MultiMarkersText)
            case text(MultiText)
            case textsWithIconsHorizontalArray([MultiTextsWithIconsHorizontal])
            case buttons(MultiButtons)
            case typeButtons(MultiTypeButtons)
        }
        
        case blockHorizontalRectangular(BlockHorizontalRectangular)
        case iconWithTwoTextLines(IconWithTwoTextLines)
        case image(ImageBlock)
        case imageSvg(ImageSvg)
        case noValid(String)
        case pageTitle(PageTitle)
        case textsWithIconHorizontal(TextsWithIconHorizontal)
        case verticalSpacing(VerticalSpacing)
        
        init(from decoder: Decoder) throws {
            
            enum CodingKeys: CodingKey {
                case type
                case data
            }

            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try? container.decode(LandingComponentsType.self, forKey: .type)
            
            switch type {
                
            case .iconWithTwoTextLines:
                let data = try container.decode(IconWithTwoTextLines.self, forKey: .data)
                self = .iconWithTwoTextLines(data)
                
            case .listHorizontalRectangleImage:
                let data = try container.decode(ListHorizontalRectangleImage.self, forKey: .data)
                self = .list(.horizontalRectangleImage(data))
                
            case .listHorizontalRoundImage:
                let data = try container.decode(ListHorizontalRoundImage.self, forKey: .data)
                self = .list(.horizontalRoundImage(data))
            
            case .listVerticalRoundImage:
                let data = try container.decode(ListVerticalRoundImage.self, forKey: .data)
                self = .list(.verticalRoundImage(data))
                
            case .multiLineHeader:
                let data = try container.decode(MultiLineHeader.self, forKey: .data)
                self = .multi(.lineHeader(data))
            
            case .multiMarkersText:
                let data = try container.decode(MultiMarkersText.self, forKey: .data)
                self = .multi(.markersText(data))
                
            case .multiText:
                let data = try container.decode(MultiText.self, forKey: .data)
                self = .multi(.text(data))
                
            case .multiTextsWithIconsHorizontal:
                let data = try container.decode([MultiTextsWithIconsHorizontal].self, forKey: .data)
                self = .multi(.textsWithIconsHorizontalArray(data))
            
            case .pageTitle:
                let data = try container.decode(PageTitle.self, forKey: .data)
                self = .pageTitle(data)
            
            case .textWithIconHorizontal:
                let data = try container.decode(TextsWithIconHorizontal.self, forKey: .data)
                self = .textsWithIconHorizontal(data)
              
            case .multiButtons:
                let data = try container.decode(MultiButtons.self, forKey: .data)
                self = .multi(.buttons(data))
                
            case .multiTypeButtons:
                let data = try container.decode(MultiTypeButtons.self, forKey: .data)
                self = .multi(.typeButtons(data))
                
            case .image:
                let data = try container.decode(ImageBlock.self, forKey: .data)
                self = .image(data)
                
            case .imageSvg:
                let data = try container.decode(ImageSvg.self, forKey: .data)
                self = .imageSvg(data)

            case .listDropDownTexts:
                let data = try container.decode(ListDropDownTexts.self, forKey: .data)
                self = .list(.dropDownTexts(data))
                
            case .verticalSpacing:
                let data = try container.decode(VerticalSpacing.self, forKey: .data)
                self = .verticalSpacing(data)
                
            case .listHorizontalRectangleLimits:
                let data = try container.decode(ListHorizontalRectangleLimits.self, forKey: .data)
                self = .list(.horizontalRectangleLimits(data))

            case .blockHorizontalRectangular:
                let data = try container.decode(BlockHorizontalRectangular.self, forKey: .data)
                self = .blockHorizontalRectangular(data)

            default:
                // не смогли распарсить - нет такого type
                self = .noValid("нет такого типа")
            }
        }
    }
}
