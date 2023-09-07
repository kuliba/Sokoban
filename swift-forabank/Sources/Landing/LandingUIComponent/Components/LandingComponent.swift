//
//  LandingComponent.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

// TODO: заменить на
// public enum LandingComponent: Hashable, Identifiable {
// …
//    public var id: Self { self }

public enum LandingComponent: Equatable, Identifiable {
    
    case list(List)
    case multi(Multi)
    
    public enum List: Equatable, Identifiable {
        case horizontalRoundImage(Landing.ListHorizontalRoundImage, Landing.ListHorizontalRoundImage.Config)
        
        public var id: UUID { .init() }
    }
    
    public enum Multi: Equatable, Identifiable {
        case lineHeader(Landing.MultiLineHeader, Landing.MultiLineHeader.Config)
        case textsWithIconsHorizontal(Landing.MultiTextsWithIconsHorizontal, Landing.MultiTextsWithIconsHorizontal.Config)
        
        public var id: UUID { .init() }
    }
    
    case pageTitle(Landing.PageTitle, Landing.PageTitle.Config)
    case textWithIconHorizontal(Landing.TextsWithIconHorizontal)
    case detailButton(Detail)
    
    // TODO: убрать после реализации всех кейсов!!!!
    case notImplemented
    /*case iconWithTwoTextLines(IconWithTwoTextLinesModel)
     case verticalSpacing(VerticalSpacingModel)
     case textWithIconHorizontal(TextWithIconHorizontalModel)
     case listHorizontalRectangleImage(ListHorizontalRectangleImageModel)
     case listVerticalRoundImage(ListVerticalRoundImageModel)
     case multiButtons(MultiButtonsModel)
     case listDropDownTexts(ListDropDownTextsModel)
     
     case image(ImageModel)*/
    
    public var id: UUID { .init() }
}
