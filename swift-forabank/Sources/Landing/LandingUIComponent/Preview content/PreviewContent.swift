//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

extension Landing.MultiLineHeader {
    
    static let defaultViewModel: Self = .init(
        regularTextList: ["Переводы"],
        boldTextList: ["за рубеж"]
    )
}

extension Landing.MultiTextsWithIconsHorizontal.Item {
    
    static let defaultItemOne: Self = .init(
        image: .bolt,
        title: "Быстро"
    )
    static let defaultItemTwo: Self = .init(
        image: .flag,
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

extension Landing.ListHorizontalRoundImage {
    
    static let defaultValue: Self = .init(
        title: "Популярные направления",
        list: .defaultValue,
        config: .defaultValue
    )
    
    static let defaultValueWithoutTitle: Self = .init(
        title: nil,
        list: .defaultValue,
        config: .defaultValue
    )
    
}

extension Array where Element == Landing.ListHorizontalRoundImage.ListItem {
    
    static let defaultValue: Self = [
        .init(
            image: .bolt,
            title: "Армения",
            subInfo: "1%",
            detail: .init(
                groupId: "forCountriesList",
                viewId: "Armeniya")
        ),
        .init(
            image: .shield,
            title: "Узбекистан",
            subInfo: "1.5%",
            detail: .init(
                groupId: "forCountriesList",
                viewId: "Uzbekistan")
        ),
        .init(
            image: .percent,
            title: "Абхазия",
            subInfo: nil,
            detail: nil
        ),
        .init(
            image: .flag,
            title: nil,
            subInfo: nil,
            detail: nil
        )
    ]
}

extension Landing.ListHorizontalRoundImage.Config {
    
    static let defaultValue: Self = .init(
        backgroundColor: .grayLightest,
        title: .defaultValue,
        subtitle: .defaultValue,
        detail: .defaultValue
    )
}

extension Landing.ListHorizontalRoundImage.Config.Title {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .title
    )
}

extension Landing.ListHorizontalRoundImage.Config.Subtitle {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        background: .white,
        font: .title
    )
}

extension Landing.ListHorizontalRoundImage.Config.Detail {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .body
    )
}

extension Landing.MultiLineHeader.Config {
    
    static let defaultValueBlack: Self = .init(
        backgroundColor: .black,
        item: .defaultValueWhite
    )
    static let defaultValueWhite: Self = .init(
        backgroundColor: .white,
        item: .defaultValueBlack
    )
    static let defaultValueGray: Self = .init(
        backgroundColor: .gray,
        item: .defaultValueBlack
    )
}
extension Landing.MultiLineHeader.Config.Item {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        fontRegular: .title,
        fontBold: .bold(.title)())
    static let defaultValueWhite: Self = .init(
        color: .white,
        fontRegular: .title,
        fontBold: .bold(.title)())
}

extension Landing.MultiTextsWithIconsHorizontal.Config {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        font: .body)
}

extension Landing.PageTitle {
    
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

extension Landing.PageTitle.Config {
    
    static let defaultValue1: Self = .init(
        title: .init(color: .black, font: .title),
        subtitle: .init(color: .gray, font: .subheadline),
        transparency: false)
    
    static let defaultValue2: Self = .init(
        title: .init(color: .black, font: .title),
        subtitle: .init(color: .gray, font: .subheadline),
        transparency: true)
}

extension Landing {
    
    static let defaultLanding: Self = .init(
        header: .header,
        main: .main,
        footer: .empty
    )
}

extension Array where Element == LandingComponent {
    
    static let header: Self = [
        .pageTitle(.defaultValue1, .defaultValue1)
    ]
    
    static let main: Self = [
        .multi(.lineHeader(
            .defaultViewModel,
            .init(
                backgroundColor: .white,
                item: .defaultValueBlack
            )
        )),
        .list(.horizontalRoundImage(
            .defaultValue,
            .defaultValue
        ))
    ]
    
    static let empty: Self = []
}
