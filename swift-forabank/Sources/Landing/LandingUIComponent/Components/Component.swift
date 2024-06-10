//
//  LandingComponent.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

extension UILanding {
    
    public enum Component: Hashable, Identifiable {
        
        case list(List)
        case multi(Multi)
        case pageTitle(UILanding.PageTitle)
        case textWithIconHorizontal(UILanding.TextsWithIconHorizontal)
        case iconWithTwoTextLines(UILanding.IconWithTwoTextLines)
        case image(UILanding.ImageBlock)
        case imageSvg(UILanding.ImageSvg)
        case verticalSpacing(UILanding.VerticalSpacing)
        
        public var id: Self { self }
    }
}

extension UILanding.Component {
    
    public enum List: Hashable, Identifiable {

        case dropDownTexts(UILanding.List.DropDownTexts)
        case horizontalRectangleImage(UILanding.List.HorizontalRectangleImage)
        case horizontalRectangleLimits(UILanding.List.HorizontalRectangleLimits)
        case horizontalRoundImage(UILanding.List.HorizontalRoundImage)
        case verticalRoundImage(UILanding.List.VerticalRoundImage)

        public var id: Self { self }
    }
    
    public enum Multi: Hashable, Identifiable {
        case buttons(UILanding.Multi.Buttons)
        case lineHeader(UILanding.Multi.LineHeader)
        case markersText(UILanding.Multi.MarkersText)
        case texts(UILanding.Multi.Texts)
        case textsWithIconsHorizontal(UILanding.Multi.TextsWithIconsHorizontal)
        case typeButtons(UILanding.Multi.TypeButtons)
        
        public var id: Self { self }
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
            case let .horizontalRectangleLimits(data):
                return data.imageRequests()
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
        }
    }
}
