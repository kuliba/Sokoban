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
        case carouselBase = "HORIZONTAL_SLIDER_BASE"
        case carouselWithTabs = "HORIZONTAL_SLIDER_WITH_TABS"
        case carouselWithDots = "HORIZONTAL_SLIDER_WITH_DOTS"
        case spacing = "SPACING"
    }

    // TODO: ListHorizontalRectangleImage -> List.Horizontal.RectangleImage
    enum DataView: Decodable, Equatable {
        
        case carousel(Carousel)
        case list(List)
        case multi(Multi)
        
        enum Carousel: Decodable, Equatable  {
            case base(CarouselBaseDecodable)
            case withTabs(CarouselWithTabsDecodable)
            case withDots(CarouselWithDotsDecodable)
        }

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
        case spacing(Spacing)
        
        init(from decoder: Decoder) throws {
            
            enum CodingKeys: CodingKey {
                case type
                case data
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try? container.decode(LandingComponentsType.self, forKey: .type)
            
            switch type {
                
            case .iconWithTwoTextLines:
                if let data = try? container.decode(IconWithTwoTextLines.self, forKey: .data) {
                    self = .iconWithTwoTextLines(data) }
                else {
                    self = .noValid("iconWithTwoTextLines")
                }
                
            case .listHorizontalRectangleImage:
                if let data = try? container.decode(ListHorizontalRectangleImage.self, forKey: .data) {
                    self = .list(.horizontalRectangleImage(data)) }
                else {
                    self = .noValid("listHorizontalRectangleImage")
                }
                
            case .listHorizontalRoundImage:
                if let data = try? container.decode(ListHorizontalRoundImage.self, forKey: .data) {
                    self = .list(.horizontalRoundImage(data)) }
                else {
                    self = .noValid("listHorizontalRoundImage")
                }
                
            case .listVerticalRoundImage:
                if let data = try? container.decode(ListVerticalRoundImage.self, forKey: .data) {
                    self = .list(.verticalRoundImage(data)) }
                else {
                    self = .noValid("listVerticalRoundImage")
                }
                
            case .multiLineHeader:
                if let data = try? container.decode(MultiLineHeader.self, forKey: .data) {
                    self = .multi(.lineHeader(data)) }
                else {
                    self = .noValid("multiLineHeader")
                }
                
            case .multiMarkersText:
                if let data = try? container.decode(MultiMarkersText.self, forKey: .data) {
                    self = .multi(.markersText(data)) }
                else {
                    self = .noValid("multiMarkersText")
                }
                
            case .multiText:
                if let data = try? container.decode(MultiText.self, forKey: .data) {
                    self = .multi(.text(data)) }
                else {
                    self = .noValid("multiText")
                }
                
            case .multiTextsWithIconsHorizontal:
                if let data = try? container.decode([MultiTextsWithIconsHorizontal].self, forKey: .data) {
                    self = .multi(.textsWithIconsHorizontalArray(data)) }
                else {
                    self = .noValid("multiTextsWithIconsHorizontal")
                }
                
            case .pageTitle:
                if let data = try? container.decode(PageTitle.self, forKey: .data) {
                    self = .pageTitle(data) }
                else {
                    self = .noValid("pageTitle")
                }
                
            case .textWithIconHorizontal:
                if let data = try? container.decode(TextsWithIconHorizontal.self, forKey: .data) {
                    self = .textsWithIconHorizontal(data) }
                else {
                    self = .noValid("textWithIconHorizontal")
                }
                
            case .multiButtons:
                if let data = try? container.decode(MultiButtons.self, forKey: .data) {
                    self = .multi(.buttons(data)) }
                else {
                    self = .noValid("multiButtons")
                }
                
            case .multiTypeButtons:
                if let data = try? container.decode(MultiTypeButtons.self, forKey: .data) {
                    self = .multi(.typeButtons(data)) }
                else {
                    self = .noValid("multiTypeButtons")
                }
                
            case .image:
                if let data = try? container.decode(ImageBlock.self, forKey: .data) {
                    self = .image(data) }
                else {
                    self = .noValid("image")
                }
                
            case .imageSvg:
                if let data = try? container.decode(ImageSvg.self, forKey: .data) {
                    self = .imageSvg(data) }
                else {
                    self = .noValid("imageSvg")
                }
                
            case .listDropDownTexts:
                if let data = try? container.decode(ListDropDownTexts.self, forKey: .data) {
                    self = .list(.dropDownTexts(data))
                }
                else {
                    self = .noValid("listDropDownTexts")
                }
                
            case .verticalSpacing:
                if let data = try? container.decode(VerticalSpacing.self, forKey: .data) {
                    self = .verticalSpacing(data) }
                else {
                    self = .noValid("verticalSpacing")
                }
            case .spacing:
                if let data = try? container.decode(Spacing.self, forKey: .data) {
                    self = .spacing(data) }
                else {
                    self = .noValid("spacing")
                }
                
            case .listHorizontalRectangleLimits:
                if let data = try? container.decode(ListHorizontalRectangleLimits.self, forKey: .data) {
                    self = .list(.horizontalRectangleLimits(data)) }
                else {
                    self = .noValid("listHorizontalRectangleLimits")
                }
                
            case .blockHorizontalRectangular:
                if let data = try? container.decode(BlockHorizontalRectangular.self, forKey: .data) {
                    self = .blockHorizontalRectangular(data) }
                else {
                    self = .noValid("blockHorizontalRectangular")
                }
                
            case .carouselBase:
                if let data = try? container.decode(CarouselBaseDecodable.self, forKey: .data) {
                    self = .carousel(.base(data)) }
                else {
                    self = .noValid("carouselBase")
                }
                
            case .carouselWithTabs:
                if let data = try? container.decode(CarouselWithTabsDecodable.self, forKey: .data) {
                    self = .carousel(.withTabs(data)) }
                else {
                    self = .noValid("carouselWithTabs")
                }
                
            case .carouselWithDots:
                if let data = try? container.decode(CarouselWithDotsDecodable.self, forKey: .data) {
                    self = .carousel(.withDots(data)) }
                else {
                    self = .noValid("carouselWithDots")
                }
                
            default:
                // не смогли распарсить - нет такого type
                self = .noValid("нет такого типа")
            }
        }
    }
}
