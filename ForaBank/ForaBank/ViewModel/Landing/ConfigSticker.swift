//
//  ConfigSticker.swift
//  ForaBank
//
//  Created by Andrew Kurdin on 02.10.2023.
//

import LandingUIComponent
import SwiftUI

extension UILanding.Component.Config {
    
    static let stickerDefault: Self = .init(
        listHorizontalRoundImage: .stickerDefault,
        listHorizontalRectangleImage: .stickerDefault,
        listHorizontalRectangleLimits: .stickerDefault,
        listVerticalRoundImage: .stickerDefault,
        listDropDownTexts: .stickerDefault,
        multiLineHeader: .stickerDefault,
        multiTextsWithIconsHorizontal: .stickerDefault,
        multiTexts: .stickerDefault,
        multiMarkersText: .stickerDefault,
        multiButtons: .stickerDefault,
        multiTypeButtons: .stickerDefault,
        pageTitle: .stickerDefault,
        textWithIconHorizontal: .stickerDefault,
        iconWithTwoTextLines: .stickerDefault,
        image: .stickerDefault,
        imageSvg: .stickerDefault,
        verticalSpacing: .stickerDefault,
        blockHorizontalRectangular: .stickerDefault,
        offsetForDisplayHeader: 100
    )
}

extension UILanding.VerticalSpacing.Config {
    
    static let stickerDefault: Self = .init(
        spacing: .init(
            big: 12,
            small: 0,
            negativeOffset: 0
        ),
        background: .init(
            black: .mainColorsBlack,
            gray: .mainColorsGrayLightest,
            white: .textWhite)
    )
}

extension UILanding.List.HorizontalRoundImage.Config {
    
    static let stickerDefault: Self = .init(
        backgroundColor: .mainColorsGrayLightest,
        title: .init(
            color: .textSecondary,
            font: .textH3Sb18240()),
        subtitle: .init(
            color: .mainColorsGray,
            background: .white,
            font: .textBodyXsSb11140(),
            cornerRadius: 90,
            padding: .init(
                horizontal: 7,
                vertical: 5
            )
        ),
        detail: .init(
            color: .textSecondary,
            font: .textBodySR12160()),
        item: .init(
            cornerRadius: 90,
            width: 56,
            spacing: 8,
            size: .init(
                width: 80,
                height: 80
            )
        ),
        cornerRadius: 12,
        spacing: 4,
        height: 144,
        paddings: .init(
            horizontal: 16,
            vertical: 8, 
            vStackContentHorizontal: 4
        )
    )
}

extension UILanding.Multi.LineHeader.Config {
    
    static let stickerDefault: Self = .init(
        paddings: .init(
            horizontal: 16,
            vertical: 12
        ),
        item: .init(
            fontRegular: .marketingH0L40X480(),
            fontBold: .marketingH0B40X480()),
        background: .init(
            black: .mainColorsBlack,
            gray: .mainColorsGrayLightest,
            white: .textWhite),
        foreground: .init(
            fgBlack: .textSecondary,
            fgWhite: .textWhite
        )
    )
}

extension UILanding.Multi.TextsWithIconsHorizontal.Config {
    
    static let stickerDefault: Self = .init(
        color: .mainColorsGrayMedium,
        font: .textBodySM12160(),
        size: 12,
        padding: .init(
            horizontal: 12,
            vertical: 8,
            itemVertical: 8
        )
    )
}

extension UILanding.Multi.Texts.Config {
    
    static let stickerDefault: Self = .init(
        font: .textBodySR12160(),
        colors: .init(text: .textPlaceholder, background: .mainColorsGrayLightest),
        paddings: .init(
            main: .init(
                horizontal: 16,
                vertical: 8),
            inside: .init(
                horizontal: 20,
                vertical: 16
            )
        ),
        cornerRadius: 12,
        spacing: 16
    )
}

extension UILanding.PageTitle.Config {
    
    static let stickerDefault: Self = .init(
        title: .init(
            color: .textSecondary,
            font: .textH3M18240()
        ),
        subtitle: .init(
            color: .textPlaceholder,
            font: .textBodyMR14180()
        )
    )
}

extension UILanding.IconWithTwoTextLines.Config {
    
    static let stickerDefault: Self = .init(
        paddings: .init(
            horizontal: 50,
            vertical: 8),
        icon: .init(
            size: 64,
            paddingBottom: 24
        ),
        title: .init(
            font: .textH3Sb18240(),
            color: .textSecondary,
            paddingBottom: 12
        ),
        subTitle: .init(
            font: .textBodyMR14200(),
            color: .textPlaceholder,
            paddingBottom: 8
        )
    )
}

extension UILanding.List.DropDownTexts.Config {
    
    static let stickerDefault: Self = .init(
        fonts: Fonts(
            title: .textH3Sb18240(),
            itemTitle: .textBodyMR14180(),
            itemDescription: .textBodyMR14180()
        ),
        colors: Colors(
            title: .textSecondary,
            itemTitle: .mainColorsBlack,
            itemDescription: .mainColorsGray
        ),
        paddings: .init(
            horizontal: 16,
            vertical: 8,
            titleTop: 12,
            titleHorizontal: 16,
            itemVertical: 16,
            itemHorizontal: 16
        ),
        heights: .init(
            title: 24,
            item: 64
        ),
        backgroundColor: .mainColorsGrayLightest,
        cornerRadius: 16,
        divider: .blurMediumGray30,
        chevronDownImage: .ic24ChevronDown
    )
}

extension UILanding.List.VerticalRoundImage.Config {
    
    static let stickerDefault: Self = .init(
        padding: .init(
            horizontal: 16,
            vertical: 8
        ),
        title: Title(
            font: .textH3Sb18240(),
            color: .textSecondary,
            paddingHorizontal: 16,
            paddingTop: 16
        ),
        divider: .blurMediumGray30,
        spacings: Spacings(
            lazyVstack: 13,
            itemHstack: 16,
            buttonHStack: 16,
            itemVStackBetweenTitleSubtitle: 4
        ),
        item: ListItem(
            imageWidthHeight: 40,
            hstackAlignment: .top,
            font: .init(
                title: .textH4M16240(),
                titleWithOutSubtitle: .textBodyMR14180(),
                subtitle: .textBodyMR14180()
            ),
            color: .init(
                title: .textSecondary,
                subtitle: .textPlaceholder
            ),
            padding: .init(
                horizontal: 16,
                vertical: 3
            )
        ),
        listVerticalPadding: 13,
        componentSettings: .init(
            background: .mainColorsGrayLightest,
            cornerRadius: 12
        ),
        buttonSettings: .init(
            circleFill: .white,
            circleWidthHeight: 40,
            ellipsisForegroundColor: .textSecondary,
            text: .init(
                font: .textH3Sb18240(),
                color: .textSecondary
            ),
            padding: .init(
                horizontal: 16,
                vertical: 3
            )
        )
    )
}
extension UILanding.Multi.Buttons.Config {
    
    static let stickerDefault: Self = .init(
        settings: .init(
            spacing: 8,
            padding: .init(
                horiontal: 16,
                top: 8,
                bottom: 48
            )
        ),
        buttons: .init(
            backgroundColors: .init(
                first: .buttonPrimary,
                second: .buttonSecondary
            ),
            textColors: .init(
                first: .white,
                second: .textSecondary
            ),
            padding: .init(
                horiontal: 16,
                vertical: 16),
            font: .textH3Sb18240(),
            height: 56,
            cornerRadius: 12
        )
    )
}

extension UILanding.TextsWithIconHorizontal.Config {
    
    static let stickerDefault: Self = .init(
        paddings: .init(
            horizontal: 16,
            vertical: 8
        ),
        backgroundColor: .mainColorsGrayLightest,
        cornerRadius: 20,
        circleSize: 32,
        icon: .init(
            width: 24,
            height: 24,
            placeholderColor: .buttonSecondary,
            padding: .init(
                vertical: 0,
                leading: 12
            )
        ),
        height: 40,
        spacing: 12,
        text: .init(
            color: .textSecondary,
            font: .textBodyMR14200()
        )
    )
}

extension UILanding.ImageBlock.Config {
    
    static let stickerDefault: Self = .init(
        background: .init(
            black: .mainColorsBlack,
            gray: .mainColorsGrayLightest,
            white: .textWhite,
            defaultColor: .textWhite),
        paddings: .init(
            horizontal: 0,
            vertical: 0
        ),
        cornerRadius: 0,
        negativeBottomPadding: 61
    )
}

extension UILanding.ImageSvg.Config {
    
    static let stickerDefault: Self = .init(
        background: .init(
            black: .mainColorsBlack,
            gray: .mainColorsGrayLightest,
            white: .textWhite,
            defaultColor: .textWhite),
        paddings: .init(
            horizontal: 16,
            vertical: 12
        ),
        cornerRadius: 12
    )
}

extension UILanding.List.HorizontalRectangleImage.Config {
    
    static let stickerDefault: Self = .init(
        cornerRadius: 12,
        size: .init(
            height: 124,
            width: 272
        ),
        paddings: .init(
            horizontal: 16,
            vertical: 8
        ),
        spacing: 8
    )
}

extension UILanding.List.HorizontalRectangleLimits.Config {
    
    static let stickerDefault: Self = .init(
        colors: .init(
            arc: .mainColorsGray,
            background: .mainColorsGrayLightest,
            divider: .blurMediumGray30,
            title: .textSecondary,
            subtitle: .textPlaceholder,
            limitNotSet: .textTertiary
        ),
        cornerRadius: 12,
        fonts: .init(title: .textBodyMR14180(), subTitle: .textBodySR12160(), limit: .textH4R16240()),
        paddings: .init(horizontal: 12, vertical: 8),
        sizes: .init(height: 176, icon: 20, width: 180),
        spacing: 8)
}

extension UILanding.BlockHorizontalRectangular.Config {
    
    static let stickerDefault: Self = .init(
        colors: .init(
            background: .mainColorsGrayLightest,
            divider: .blurMediumGray30,
            title: .textSecondary,
            subtitle: .textPlaceholder,
            warning: .mainColorsRed
        ),
        cornerRadius: 12,
        sizes: .init(
            iconWidth: 24,
            height: 124,
            width: 272
        ),
        paddings: .init(
            horizontal: 16,
            vertical: 8
        ),
        spacing: 8
    )
}

extension UILanding.Multi.TypeButtons.Config {
    
    static let stickerDefault: Self = .init(
        paddings: .init(
            horizontal: 16,
            top: 12,
            bottom: 24
        ),
        cornerRadius: 12,
        fonts: .init(
            into: .textBodyMR14200(),
            button: .textH3Sb18240()
        ),
        spacing: 44,
        sizes: .init(
            imageInfo: 24,
            heightButton: 56
        ),
        colors: .init(
            background: .init(
                black: .mainColorsBlack,
                gray: .mainColorsGrayLightest,
                white: .textWhite
            ),
            button: .buttonPrimary,
            buttonText: .mainColorsWhite,
            foreground: .init(
                fgBlack: .textSecondary,
                fgWhite: .textWhite
            )
        )
    )
}

extension UILanding.Multi.MarkersText.Config {
    
    static let stickerDefault: Self = .init(
        colors: .init(
            foreground: .init(
                black: .textSecondary,
                white: .mainColorsWhite,
                defaultColor: .white),
            backgroud: .init(
                gray: .mainColorsGrayLightest,
                black: .mainColorsBlack,
                white: .textWhite,
                defaultColor: .white
            )
        ),
        vstack: .init(
            padding: .init(
                leading: 16,
                trailing: 23,
                vertical: 8
            )
        ),
        internalContent: .init(
            spacing: 4,
            cornerRadius: 12,
            lineTextLeadingPadding: 8,
            textFont: .textBodyMR14200()
        )
    )
}
