//
//  PreviewContent.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

extension UILanding.Multi.LineHeader {
    
    static let defaultViewModelWhite: Self = .init(
        backgroundColor: "WHITE",
        regularTextList: ["Переводы"],
        boldTextList: ["за рубеж"]
    )
    
    static let defaultViewModelGray: Self = .init(
        backgroundColor: "GREY",
        regularTextList: ["Переводы"],
        boldTextList: ["за рубеж"]
    )
    
    static let defaultViewModelBlack: Self = .init(
        backgroundColor: "BLACK",
        regularTextList: ["Переводы"],
        boldTextList: ["за рубеж"]
    )
}

extension UILanding.Multi.TextsWithIconsHorizontal.Item {
    
    static let defaultItemOne: Self = .init(
        md5hash: "1",
        title: "Быстро"
    )
    static let defaultItemTwo: Self = .init(
        md5hash: "2",
        title: "Безопасно"
    )
}

extension Color {
    
    static let grayColor: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
    static let textSecondary: Self = .init(red: 0.11, green: 0.11, blue: 0.11)
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
}

extension Image {
    
    static let bolt: Self = .init(systemName: "bolt")
    static let percent: Self = .init(systemName: "percent")
    static let shield: Self = .init(systemName: "shield")
    static let flag: Self = .init(systemName: "flag")
    
}

extension UILanding.List.HorizontalRoundImage {
    
    static let defaultValue: Self = .init(
        title: "Популярные направления",
        list: .defaultValue
    )
    
    static let defaultValueWithoutTitle: Self = .init(
        title: nil,
        list: .defaultValue
    )
    
}

extension Array where Element == UILanding.List.HorizontalRoundImage.ListItem {
    
    static let defaultValue: Self = [
        .init(
            imageMd5Hash: "1",
            title: "Армения",
            subInfo: "1%",
            detail: .init(
                groupId: "forCountriesList",
                viewId: "Armeniya")
        ),
        .init(
            imageMd5Hash: "2",
            title: "Узбекистан",
            subInfo: "1.5%",
            detail: .init(
                groupId: "forCountriesList",
                viewId: "Uzbekistan")
        ),
        .init(
            imageMd5Hash: "3",
            title: "Абхазия",
            subInfo: nil,
            detail: nil
        ),
        .init(
            imageMd5Hash: "4",
            title: nil,
            subInfo: nil,
            detail: nil
        )
    ]
}

extension UILanding.List.HorizontalRoundImage.Config {
    
    static let defaultValue: Self = .init(
        backgroundColor: .grayColor,
        title: .defaultValue,
        subtitle: .defaultValue,
        detail: .defaultValue,
        item: .init(
            cornerRadius: 28,
            width: 56,
            spacing: 8,
            size: .init(width: 10, height: 10)),
        cornerRadius: 12,
        spacing: 16,
        height: 184,
        paddings: .init(horizontal: 16,
                        vertical: 8,
                        vStackContentHorizontal: 16))
}

extension UILanding.List.HorizontalRoundImage.Config.Title {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .title
    )
}

extension UILanding.List.HorizontalRoundImage.Config.Subtitle {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        background: .white,
        font: .title,
        cornerRadius: 12,
        padding: .init(horizontal: 6, vertical: 6)
    )
}

extension UILanding.List.HorizontalRoundImage.Config.Detail {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .body
    )
}

extension UILanding.Multi.LineHeader.Config {
    
    static let defaultValue: Self = .init(
        paddings: .init(horizontal: 0, vertical: 0),
        item: .defaultValueWhite,
        background: .init(
            black: /*Main colors/Black*/.black,
            gray: .grayLightest /*Main colors/Gray lightest*/,
            white: .white /*Text/White*/),
        foreground: .init(fgBlack: .black /*Text/secondary*/, fgWhite: .white/*Text/White*/)
    )
}
extension UILanding.Multi.LineHeader.Config.Item {
    
    static let defaultValueBlack: Self = .init(
        fontRegular: .title,
        fontBold: .bold(.title)())
    static let defaultValueWhite: Self = .init(
        fontRegular: .title,
        fontBold: .bold(.title)())
}

extension UILanding.Multi.TextsWithIconsHorizontal.Config {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        font: .body,
        size: 12,
        padding: .init(horizontal: 16, vertical: 8, itemVertical: 8)
    )
}

extension UILanding.PageTitle {
    
    static let defaultValue1: Self = .init(
        text: "Выберите продукт",
        subTitle: nil,
        transparency: false
    )
    
    static let defaultValue2: Self = .init(
        text: "Платежный стикер",
        subTitle: "за 700 р.",
        transparency: true
    )
}

extension UILanding.PageTitle.Config {
    
    static let defaultValue1: Self = .init(
        title: .init(color: .black, font: .title),
        subtitle: .init(color: .gray, font: .subheadline))
    
    static let defaultValue2: Self = .init(
        title: .init(color: .black, font: .title),
        subtitle: .init(color: .gray, font: .subheadline))
}

extension UILanding {
    
    static let defaultLanding: Self = .init(
        header: .header,
        main: .main,
        footer: .empty,
        details: .empty
    )
}

extension Array where Element == UILanding.Component {
    
    static let header: Self = [
        .pageTitle(.defaultValue1)
    ]
    
    static let main: Self = [
        .multi(.lineHeader(
            .defaultViewModelBlack
        )),
        .list(.horizontalRoundImage(.defaultValue))
    ]
    
    static let footer: Self = [
        .pageTitle(.defaultValue2)
    ]
    
    
    static let empty: Self = []
}

extension Array where Element == UILanding.Detail {
    
    static let empty: Self = []
}

extension Dictionary where Key == String, Value == Image {
    
    static let defaultValue: Self = [
        "1": .bolt,
        "2": .flag,
        "3": .shield
    ]
}

extension UILanding.Multi.Texts.Config {
    
    static let defaultValue: Self = .init(
        font: .body,
        colors: .init(text: .grayColor, background: .blue),
        paddings: .init(
            main: .init(horizontal: 16, vertical: 8),
            inside: .init(horizontal: 16, vertical: 20)),
        cornerRadius: 12,
        spacing: 16)
}

extension UILanding.Component.Config {
    
    static let defaultValue: Self = .init(
        listHorizontalRoundImage: .defaultValue,
        listHorizontalRectangleImage: .default,
        listHorizontalRectangleLimits: .default,
        listVerticalRoundImage: .default,
        listDropDownTexts: .defaultDropDownTextsConfig,
        multiLineHeader: .defaultValue,
        multiTextsWithIconsHorizontal: .defaultValueBlack,
        multiTexts: .defaultValue,
        multiMarkersText: .defaultConfig,
        multiButtons: .default,
        multiTypeButtons: .default,
        pageTitle: .defaultValue1,
        textWithIconHorizontal: .default,
        iconWithTwoTextLines: .defaultValue,
        image: .default,
        imageSvg: .default,
        verticalSpacing: .defaultValue,
        offsetForDisplayHeader: 100)
}

extension Placeholder {
    static let widthConfig = Placeholder.Config.Width(title: 210, subtitle: 190, banner: 288, bonuses3inRow: 82)
    static let heightConfig = Placeholder.Config.Height(titleAndSubtitle: 25, bonuses: 18, popularDestinationView: 144, maxTransfersPerMonth: 40, bannersView: 124, listOfCountries: 415, advantagesAndSupport: 313, faq: 415, reference: 112)
    static let paddingConfig = Placeholder.Config.Padding(globalHorizontal: 16, globalBottom: 27, titleBottom: 54)
    static let spacingConfig = Placeholder.Config.Spacing(titleViewSpacing: 12, globalVStack: 16, bonuses3inRow: 18, bannersView: 8)
    static let cornerRadiusConfig = Placeholder.Config.CornerRadius(roundedRectangle: 12, maxCornerRadius: 90)
    static let gradientColorConfig = Placeholder.Config.GradientColor(fromLeft: Color.gray.opacity(0.1), toRight: Color.gray.opacity(0.3))
}

extension Placeholder.Config {
    static let defaultValue: Self = .init(width: Placeholder.widthConfig,
                                          height: Placeholder.heightConfig,
                                          padding: Placeholder.paddingConfig,
                                          spacing: Placeholder.spacingConfig,
                                          cornerRadius: Placeholder.cornerRadiusConfig,
                                          gradientColor: Placeholder.gradientColorConfig)
}

extension UILanding.IconWithTwoTextLines {
    
    static let `default`: UILanding.IconWithTwoTextLines = .init(
        md5hash: "ya.ru",
        title: "Больше возможностей при переводах в Армению",
        subTitle: "Теперь до 1 000 000 Р")
    
    static let clearValue: UILanding.IconWithTwoTextLines = .init(
        md5hash: "ya.ru",
        title: nil,
        subTitle: nil)
}

extension UILanding.IconWithTwoTextLines.Config {
    
    static let defaultValue: Self = .init(
        paddings: .init(horizontal: 50, vertical: 8),
        icon: .init(size: 64, paddingBottom: 24),
       // horizontalPadding: 50,
        title: TextConfig(font: .system(size: 18), color: .textSecondary, paddingBottom: 12),
        subTitle: TextConfig(font: .system(size: 14), color: .grayColor, paddingBottom: 8)
    )
}

extension UILanding.List.DropDownTexts.Config {
    
    static let defaultDropDownTextsConfig: Self = .init(
        fonts: Fonts(title: .title2, itemTitle: .body, itemDescription: .callout),
        colors: Colors(title: .black, itemTitle: .black, itemDescription: .gray),
        paddings: .init(horizontal: 16, vertical: 8, titleTop: 12, titleHorizontal: 16, itemVertical: 20, itemHorizontal: 16),
        heights: .init(title: 48, item: 64),
        backgroundColor: Color.gray,
        cornerRadius: 16, 
        divider: .gray, 
        chevronDownImage: Image("chevron-downnew")
    )
}

extension UILanding.List.DropDownTexts {
    
    static let defaultDropDownTextsDataList: UILanding.List.DropDownTexts = .init(title: "Questions", list: [
        .init(title: "Как можно отправить перевод?", description: "В мобильном приложении Фора-Банка нажмите на баннер с переводами в Армению «МИГ» на главном экране."),
        .init(title: "2 Как можно отправить перевод?", description: "2 В мобильном приложении Фора-Банка нажмите на баннер с переводами в Армению «МИГ» на главном экране"),
        .init(title: "3 Как можно отправить перевод?", description: "3 В мобильном приложении Фора-Банка нажмите на баннер с переводами в Армению «МИГ» на главном экране"),
    ])
}

extension UILanding.List.VerticalRoundImage {
    
    static let defaultValue: Self = .init(
        title: "Title",
        displayedCount: 1,
        dropButtonOpenTitle: "Show all countries",
        dropButtonCloseTitle: "hide countries",
        list: [
            .init(
                md5hash: "1",
                title: "2",
                subInfo: "3",
                link: "4",
                appStore: "5",
                googlePlay: "6",
                detail: .init(groupId: "1", viewId: "2"), 
                action: nil),
            .init(
                md5hash: "1",
                title: "3",
                subInfo: "3",
                link: "4",
                appStore: "5",
                googlePlay: "6",
                detail: .init(groupId: "1", viewId: "2"), 
                action: nil),
            .init(
                md5hash: "1",
                title: "4",
                subInfo: "3",
                link: "4",
                appStore: "5",
                googlePlay: "6",
                detail: .init(groupId: "1", viewId: "2"), 
                action: nil)
        ]
    )
}

extension UILanding.List.VerticalRoundImage.Config {
    
    static let `default`: Self = .init(
        padding: .init(horizontal: 16,
                       vertical: 8),
        title: Title(
            font: .system(size: 18),
            color: .textSecondary,
            paddingHorizontal: 16,
            paddingTop: 16), 
        divider: .gray,
        spacings: Spacings(
            lazyVstack: 13,
            itemHstack: 16,
            buttonHStack: 16,
            itemVStackBetweenTitleSubtitle: 4),
        item: ListItem(
            imageWidthHeight: 40, 
            hstackAlignment: .center,
            font: .init(title: .headline, titleWithOutSubtitle: .subheadline, subtitle: .caption),
            color: .init(title: Color.textSecondary, subtitle: .gray),
            padding: .init(horizontal: 16, vertical: 3)),
        listVerticalPadding: 13,
        componentSettings: .init(
            background: .grayLightest,
            cornerRadius: 12),
        buttonSettings: .init(
            circleFill: .white,
            circleWidthHeight: 40,
            ellipsisForegroundColor: .textSecondary,
            text: .init(font: .title3, color: Color.textSecondary),
            padding: .init(horizontal: 16, vertical: 3)))
}

extension UILanding.TextsWithIconHorizontal.Config {
    
    static let `default`: Self = .init(
        paddings: .init(horizontal: 16,
                        vertical: 8),
        backgroundColor: .black,
        cornerRadius: 20,
        circleSize: 32,
        icon: .init(width: 24,
                    height: 24,
                    placeholderColor: .grayColor,
                    padding: .init(vertical: 0, leading: 12)),
        height: 40,
        spacing: 12,
        text: .init(color: .green, font: .body))
}

extension UILanding.ImageBlock.Config {
    
    static let `default`: Self = .init(
        background: .init(
            black: /*Main colors/Black*/.black,
            gray: .grayLightest /*Main colors/Gray lightest*/,
            white: .white,
            defaultColor: .white),
        paddings: .init(horizontal: 16, vertical: 12),
        cornerRadius: 12, 
        negativeBottomPadding: 0)
}

extension UILanding.ImageSvg.Config {
    
    static let `default`: Self = .init(
        background: .init(
            black: /*Main colors/Black*/.black,
            gray: .grayLightest /*Main colors/Gray lightest*/,
            white: .white,
            defaultColor: .white),
        paddings: .init(horizontal: 16, vertical: 12),
        cornerRadius: 12)
}

extension UILanding.List.HorizontalRectangleImage.Config {
    
    static let `default`: Self = .init(
        cornerRadius: 12,
        size: .init(height: 124, width: 272),
        paddings: .init(horizontal: 16, vertical: 8),
        spacing: 8)
}

extension UILanding.List.HorizontalRectangleLimits.Config {
    
    static let `default`: Self = .init(
        cornerRadius: 12,
        size: .init(height: 124, width: 272),
        paddings: .init(horizontal: 16, vertical: 8),
        spacing: 8)
}

extension UILanding.Multi.Buttons.Config {
    
    static let `default`: Self = .init(
        settings: .init(
            spacing: 8,
            padding: .init(
                horiontal: 16,
                top: 8,
                bottom: 8)),
        buttons: .init(
            backgroundColors: .init(
                first: .red,
                second: .white),
            textColors: .init(
                first: .white,
                second: .black),
            padding: .init(
                horiontal: 16,
                vertical: 16),
            font: .title,
            height: 56,
            cornerRadius: 12))
}

extension UILanding.Multi.TypeButtons.Config {
    
    static let `default`: Self = .init(
        paddings: .init(horizontal: 16,
                        top: 12,
                        bottom: 24),
        cornerRadius: 12,
        fonts: .init(
            into: Font.custom("Inter", size: 14),
            button: Font.custom("Inter", size: 18).weight(.semibold)),
        spacing: 44,
        sizes: .init(imageInfo: 24, heightButton: 56),
        colors: .init(
            background: .init(
                black: /*Main colors/Black*/.black,
                gray: .grayLightest /*Main colors/Gray lightest*/,
                white: .white /*Text/White*/),
            button: .red /*Button/primary*/,
            buttonText: .white,
            foreground: .init(fgBlack: .black /*Text/secondary*/, fgWhite: .white/*Text/White*/)))
}

extension UILanding.Multi.TypeButtons {
    
    static let `default`: Self = .init(
        md5hash: "",
        backgroundColor: "WHITE",
        text: "Подробные условия1",
        buttonText: "Заказать1",
        buttonStyle: "whiteRed",
        textLink: "link",
        action: .init(
            type: "orderCard",
            outputData: .init(tarif: 7, type: 6)),
        detail: nil)
}

extension UILanding.VerticalSpacing.Config {
    
    static let defaultValue: Self = .init(
        spacing: .init(big: 30, small: 10, negativeOffset: -20),
        background: .init(
            black: /*Main colors/Black*/.black,
            gray: .grayLightest /*Main colors/Gray lightest*/,
            white: .white /*Text/White*/)
    )
}
// MARK: - MarkersText Model
extension UILanding.Multi.MarkersText {
    
    static let defaultModel1: UILanding.Multi.MarkersText = .init(backgroundColor: "WHITE", style: "PADDINGWITHCORNERS", list: ["Валюты счета: ₽/$/€;", "Соверши свой первый перевод в Армению в приложении Фора-Банка*", "Получи кешбэк до 1 000 ₽*"])
    
    static let defaultModel2: UILanding.Multi.MarkersText = .init(backgroundColor: "GREY", style: "PADDING", list: ["Валюты счета: ₽/$/€;", "Кешбэк: до 20% у партнеров; 7% сезонный; 2% - канцтовары; 1,2% - остальные покупки, до 20 000 ₽/мес", "Кредитный лимит до 1 500 000 ₽, ставка от 17% годовых"])
    
    static let defaultModel3: UILanding.Multi.MarkersText = .init(backgroundColor: "BLACK", style: "FILL", list: ["Кешбэк: до 20% партнерский; 5% сезонный; 2% - канцтовары; 1,1% - остальные покупки", "Кешбэк в рублях до 10 000 ₽ /мес.;", "Обслуживание от 0 ₽;", "Бонусы и кешбэк по «Привет, Мир!»"])
}

// MARK: - MarkersText Config
extension UILanding.Multi.MarkersText.Config {
    
    static let defaultConfig: Self = .init(
        colors: .init(
            foreground: .init(
                black: .textSecondary,
                white: .white,
                defaultColor: .white),
            backgroud: .init(
                gray: .grayLightest,
                black: .black,
                white: .white,
                defaultColor: .white)),
        vstack: .init(padding: .init(leading: 16, trailing: 23, vertical: 8)),
        internalContent: .init(
            spacing: 4,
            cornerRadius: 12,
            lineTextLeadingPadding: 8,
            textFont: .system(size: 14)))
}
