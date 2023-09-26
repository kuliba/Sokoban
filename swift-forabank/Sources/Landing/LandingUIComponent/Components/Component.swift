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
        
        public enum List: Hashable, Identifiable {
            case horizontalRoundImage(UILanding.List.HorizontalRoundImage)
            case horizontalRectangleImage(UILanding.List.HorizontalRectangleImage)
            case verticalRoundImage(UILanding.List.VerticalRoundImage)
            case dropDownTexts(UILanding.List.DropDownTexts)
            
            public var id: Self { self }
        }
        
        public enum Multi: Hashable, Identifiable {
            case lineHeader(UILanding.Multi.LineHeader)
            case textsWithIconsHorizontal(UILanding.Multi.TextsWithIconsHorizontal)
            case texts(UILanding.Multi.Texts)
            case markersText(UILanding.Multi.MarkersText)
            case buttons(UILanding.Multi.Buttons)
            case typeButtons(UILanding.Multi.TypeButtons)
            
            public var id: Self { self }
        }
        
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
    
    func imageRequests() -> [ImageRequest] {
        
        switch self {
        case let .list(list):
            switch list {
            case let .horizontalRoundImage(data):
                return data.imageRequests()
            case let .horizontalRectangleImage(data):
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
