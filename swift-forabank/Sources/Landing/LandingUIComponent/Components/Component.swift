//
//  LandingComponent.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

extension UILanding {
    
    public enum Component: Equatable {
        
        case blockHorizontalRectangular(UILanding.BlockHorizontalRectangular)

        case iconWithTwoTextLines(UILanding.IconWithTwoTextLines)
        case image(UILanding.ImageBlock)
        case imageSvg(UILanding.ImageSvg)
        case carousel(Carousel)
        case list(List)
        case multi(Multi)
        case pageTitle(UILanding.PageTitle)
        case textWithIconHorizontal(UILanding.TextsWithIconHorizontal)
        case verticalSpacing(UILanding.VerticalSpacing)
        
        var id: String {
            switch self {
            case let .list(list):
                switch list {
                case let .horizontalRectangleLimits(limitsState):
                    return limitsState.id.uuidString
                default:
                    return list.id.uuidString
                }
            case let .multi(multi):
                return multi.id.uuidString
            case let .pageTitle(pageTitle):
                return pageTitle.id.uuidString
            case let .textWithIconHorizontal(textsWithIconHorizontal):
                return textsWithIconHorizontal.md5hash
            case let .iconWithTwoTextLines(iconWithTwoTextLines):
                return iconWithTwoTextLines.md5hash
            case let .image(imageBlock):
                return imageBlock.id.uuidString
            case let .imageSvg(imageSvg):
                return imageSvg.md5hash.rawValue
            case let .verticalSpacing(verticalSpacing):
                return verticalSpacing.id.uuidString
            case let .blockHorizontalRectangular(value):
                return value.id.uuidString
            case let .carousel(value):
                return value.id.uuidString
            }
        }
        
        public var listHorizontalLimitsState: ListHorizontalRectangleLimitsState? {
            
            switch self {
            case let .list(list):
                switch list {
                case let .horizontalRectangleLimits(value):
                    return value
                default:
                    return nil
                }
                
            default:
                return nil
            }
        }
    }
}

extension UILanding.Component {
    
    public enum Carousel: Equatable {
        
        case base(UILanding.Carousel.CarouselBase)
        
        public var id: UUID {
            switch self {
            case let .base(value):
                return value.id
            }
        }
    }
}

extension UILanding.Component {
    
    public enum List: Equatable { 

        case dropDownTexts(UILanding.List.DropDownTexts)
        case horizontalRectangleImage(UILanding.List.HorizontalRectangleImage)
        case horizontalRectangleLimits(ListHorizontalRectangleLimitsState)
        case horizontalRoundImage(UILanding.List.HorizontalRoundImage)
        case verticalRoundImage(UILanding.List.VerticalRoundImage)
        
        public var id: UUID {
            switch self {
            case let .dropDownTexts(value):
                return value.id
            case let .horizontalRectangleImage(value):
                return value.id
            case let .horizontalRectangleLimits(value): // ??? need add limits id
                return value.id
            case let .horizontalRoundImage(value):
                return value.id
            case let .verticalRoundImage(value):
                return value.id
            }
        }
    }
    
    public enum Multi: Equatable {
        case buttons(UILanding.Multi.Buttons)
        case lineHeader(UILanding.Multi.LineHeader)
        case markersText(UILanding.Multi.MarkersText)
        case texts(UILanding.Multi.Texts)
        case textsWithIconsHorizontal(UILanding.Multi.TextsWithIconsHorizontal)
        case typeButtons(UILanding.Multi.TypeButtons)
        
        public var id: UUID {
            switch self {
            case let .buttons(value):
                return value.id
            case let .lineHeader(value):
                return value.id
            case let .markersText(value):
                return value.id
            case let .texts(value):
                return value.id
            case let .textsWithIconsHorizontal(value):
                return value.id
            case let .typeButtons(value):
                return value.id
            }
        }
    }
}

extension UILanding.Component {
    
    func imageRequests() -> [ImageRequest] {
        
        switch self {
        case let .list(list):
            switch list {
            case let .horizontalRoundImage(data):
                return data.imageRequests()
            case let .horizontalRectangleImage(data):
                return data.imageRequests()
            case .horizontalRectangleLimits:
                return []
            case let .verticalRoundImage(data):
                return data.imageRequests()
            case let .dropDownTexts(data):
                return data.imageRequests()
            }
        case let .multi(multi):
            switch multi {
            case let .lineHeader(data):
                return data.imageRequests()
            case let .textsWithIconsHorizontal(data):
                return data.imageRequests()
            case let .texts(data):
                return data.imageRequests()
            case let .markersText(data):
                return data.imageRequests()
            case let .buttons(data):
                return data.imageRequests()
            case let .typeButtons(data):
                return data.imageRequests()
            }
        case let .pageTitle(data):
            return data.imageRequests()
        case let .textWithIconHorizontal(data):
            return data.imageRequests()
        case let .iconWithTwoTextLines(data):
            return data.imageRequests()
        case let .image(data):
            return data.imageRequests()
        case let .imageSvg(data):
            return data.imageRequests()
        case let .verticalSpacing(data):
            return data.imageRequests()
        case .blockHorizontalRectangular:
            return []
            
        case let .carousel(data):
            return []
        }
    }
}
