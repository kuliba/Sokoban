//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

extension Array where Element == MultiLineHeaderViewModel.Item {
    
    static let regularTextItems: Self = [
        .init(
            id: "1",
            name: "Переводы"
        )]
    static let boldTextItems: Self = [
        .init(
            id: "2",
            name: "за рубеж"
        )]
}

extension MultiLineHeaderViewModel {
    
    static let defaultViewModelBlack: Self = .init(
        regularTextItems: .regularTextItems,
        boldTextItems: .boldTextItems
    )
    
    static let defaultViewModelGray: Self = .init(
        regularTextItems: .regularTextItems,
        boldTextItems: .boldTextItems
    )
    
    static let defaultViewModelWhite: Self = .init(
        regularTextItems: .regularTextItems,
        boldTextItems: .boldTextItems
    )
}

extension Array where Element == MultiTextsWithIconsHorizontalViewModel.Item {
    
    static let defaultValue: Self = [
        .init(
            id: UUID().uuidString,
            image: .bolt,
            title: .defaultItemOne),
        .init(
            id: UUID().uuidString,
            image: .shield,
            title: .defaultItemTwo),
        .init(
            id: UUID().uuidString,
            image: .percent,
            title: nil)
    ]
}

extension MultiTextsWithIconsHorizontalViewModel.TextItem {
    
    static let defaultItemOne: Self = .init(
        title: "Быстро"
    )
    static let defaultItemTwo: Self = .init(
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

extension ListHorizontalRoundImageViewModel {
    
    static let defaultValue: Self = .init(
        title: "Популярные направления",
        items: .defaultValue
    )
    
    static let defaultValueWithoutTitle: Self = .init(
        title: nil,
        items: .defaultValue
    )

}

extension Array where Element == ListHorizontalRoundImageViewModel.Item {
    
    static let defaultValue: Self = [
        .init(
            id: "1",
            title: "Армения",
            image: .bolt,
            subInfo: .init(text: "1%"),
            details: .init(
                detailsGroupId: "forCountriesList",
                detailViewId: "Armeniya")
        ),
        .init(
            id: "2",
            title: "Узбекистан",
            image: .shield,
            subInfo: .init(text: "1.5%"),
            details: .init(
                detailsGroupId: "forCountriesList",
                detailViewId: "Uzbekistan")
        ),
        .init(
            id: "3",
            title: "Абхазия",
            image: .percent,
            subInfo: nil,
            details: nil
        ),
        .init(
            id: "4",
            title: nil,
            image: .flag,
            subInfo: nil,
            details: nil
        )
    ]
}

extension ListHorizontalRoundImageView.Config {
    
    static let defaultValue: Self = .init(
        backgroundColor: .grayLightest,
        title: .defaultValue,
        subtitle: .defaultValue,
        detail: .defaultValue
    )
}

extension ListHorizontalRoundImageView.Config.Title {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .title
    )
}

extension ListHorizontalRoundImageView.Config.Subtitle {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        background: .white,
        font: .title
    )
}

extension ListHorizontalRoundImageView.Config.Detail {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .body
    )
}

extension MultiLineHeaderView.Config {
    
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
extension MultiLineHeaderView.Config.Item {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        fontRegular: .title,
        fontBold: .bold(.title)())
    static let defaultValueWhite: Self = .init(
        color: .white,
        fontRegular: .title,
        fontBold: .bold(.title)())
}

extension MultiTextsWithIconsHorizontalView.Config {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        font: .body)
}
