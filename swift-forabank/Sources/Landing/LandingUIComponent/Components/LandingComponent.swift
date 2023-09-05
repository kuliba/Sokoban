//
//  LandingComponent.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Foundation

public enum LandingComponent: Equatable, Identifiable {
    
    case listHorizontalRoundImage(Landing.ListHorizontalRoundImage, Landing.ListHorizontalRoundImage.Config)
    case multiLineHeader(Landing.MultiLineHeader, Landing.MultiLineHeader.Config)
    case multiTextsWithIconsHorizontal(Landing.MultiTextsWithIconsHorizontal, Landing.MultiTextsWithIconsHorizontal.Config)
    case pageTitle(Landing.PageTitle, Landing.PageTitle.Config)
    case textWithIconHorizontal(Landing.TextsWithIconHorizontal)
    case detailButton(Detail)
    case empty
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
