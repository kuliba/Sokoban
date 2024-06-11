//
//  ComponentConfig.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Foundation

extension UILanding.Component {
    
    public struct Config {
        
        public let listHorizontalRoundImage: UILanding.List.HorizontalRoundImage.Config
        public let listHorizontalRectangleImage: UILanding.List.HorizontalRectangleImage.Config
        public let listHorizontalRectangleLimits: UILanding.List.HorizontalRectangleLimits.Config
        public let listVerticalRoundImage: UILanding.List.VerticalRoundImage.Config
        public let listDropDownTexts: UILanding.List.DropDownTexts.Config
        public let multiLineHeader: UILanding.Multi.LineHeader.Config
        public let multiTextsWithIconsHorizontal: UILanding.Multi.TextsWithIconsHorizontal.Config
        public let multiTexts: UILanding.Multi.Texts.Config
        public let multiMarkersText: UILanding.Multi.MarkersText.Config
        public let multiButtons: UILanding.Multi.Buttons.Config
        public let multiTypeButtons: UILanding.Multi.TypeButtons.Config
        public let pageTitle: UILanding.PageTitle.Config
        public let textWithIconHorizontal: UILanding.TextsWithIconHorizontal.Config
        public let iconWithTwoTextLines: UILanding.IconWithTwoTextLines.Config
        public let image: UILanding.ImageBlock.Config
        public let imageSvg: UILanding.ImageSvg.Config
        public let verticalSpacing: UILanding.VerticalSpacing.Config
        public let blockHorizontalRectangular: UILanding.BlockHorizontalRectangular.Config

        let offsetForDisplayHeader: CGFloat
        
        public init(
            listHorizontalRoundImage: UILanding.List.HorizontalRoundImage.Config,
            listHorizontalRectangleImage: UILanding.List.HorizontalRectangleImage.Config,
            listHorizontalRectangleLimits: UILanding.List.HorizontalRectangleLimits.Config,
            listVerticalRoundImage: UILanding.List.VerticalRoundImage.Config,
            listDropDownTexts: UILanding.List.DropDownTexts.Config,
            multiLineHeader: UILanding.Multi.LineHeader.Config,
            multiTextsWithIconsHorizontal: UILanding.Multi.TextsWithIconsHorizontal.Config,
            multiTexts: UILanding.Multi.Texts.Config,
            multiMarkersText: UILanding.Multi.MarkersText.Config,
            multiButtons: UILanding.Multi.Buttons.Config,
            multiTypeButtons: UILanding.Multi.TypeButtons.Config,
            pageTitle: UILanding.PageTitle.Config,
            textWithIconHorizontal: UILanding.TextsWithIconHorizontal.Config,
            iconWithTwoTextLines: UILanding.IconWithTwoTextLines.Config,
            image: UILanding.ImageBlock.Config,
            imageSvg: UILanding.ImageSvg.Config,
            verticalSpacing: UILanding.VerticalSpacing.Config,
            blockHorizontalRectangular: UILanding.BlockHorizontalRectangular.Config,
            offsetForDisplayHeader: CGFloat
        ) {
            self.listHorizontalRoundImage = listHorizontalRoundImage
            self.listHorizontalRectangleImage = listHorizontalRectangleImage
            self.listHorizontalRectangleLimits = listHorizontalRectangleLimits
            self.listVerticalRoundImage = listVerticalRoundImage
            self.listDropDownTexts = listDropDownTexts
            self.multiLineHeader = multiLineHeader
            self.multiTextsWithIconsHorizontal = multiTextsWithIconsHorizontal
            self.multiTexts = multiTexts
            self.multiMarkersText = multiMarkersText
            self.multiButtons = multiButtons
            self.multiTypeButtons = multiTypeButtons
            self.pageTitle = pageTitle
            self.textWithIconHorizontal = textWithIconHorizontal
            self.iconWithTwoTextLines = iconWithTwoTextLines
            self.image = image
            self.imageSvg = imageSvg
            self.verticalSpacing = verticalSpacing
            self.blockHorizontalRectangular = blockHorizontalRectangular
            self.offsetForDisplayHeader = offsetForDisplayHeader
        }
    }
}
