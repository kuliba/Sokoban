//
//  PreviewContent.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI

extension ClientInformListConfig.Colors {
    
    static let preview: Self = .init(

        bgIconRedLight: Color(red: 1.00, green: 0.62, blue: 0.62)
    )
}

extension Image {
    
    static let clock: Self = .init(systemName: "clock")
    static let infoCircle: Self = .init(systemName: "info.circle")
}

extension ClientInformListConfig.Strings {
    
    static let preview: Self = .init(
        titlePlaceholder: "Информация",
        foraBankLink: "https://www.forabank.ru"
    )
}

@available(iOS 15, *)
extension ClientInformListDataState {
    
//    static let preview: Self = ClientInformListDataState.single(.init(label: .init(image: .clock, title: "Urgent Info"), text: "please drop your phone! Alarm!"))

    static let preview: Self = ClientInformListDataState.multiple(.init(
        title: Label(image: .infoCircle, title: "Информация"),
        items: [
            Label(image: .clock, title: "Время работы изменилось на 13:00 - 15:00"),
            Label(image: .infoCircle, title: "Информация на главном портале обновилась"),
            Label(image: .clock, title: "Время работы изменилось на 13:00 - 15:00"),
            Label(image: .infoCircle, title: "Информация на главном портале обновилась"),
            Label(image: .clock, title: "Время работы изменилось на 13:00 - 15:00"),
            Label(image: .infoCircle, title: "Информация на главном портале обновилась"),
            Label(image: .clock, title: "Время работы изменилось на 13:00 - 15:00"),
            Label(image: .infoCircle, title: "Информация на главном портале обновилась"),
            Label(image: .clock, title: "Время работы изменилось на 13:00 - 15:00")
        ]
    ))
}

extension ClientInformListConfig {
    
    static let `default`: Self = .init(
        colors: .preview,
        strings: .preview,
        titleConfig: .init(
            textFont: .title,
            textColor: .black
        ),
        textConfig: .init(
            textFont: .caption2,
            textColor: .black
        ),
        sizes: .init(
            iconSize: 40,
            iconBackgroundSize: 64,
            rowIconSize: 40,
            navBarHeight: 59,
            navBarMaxWidth: 48,
            spacing: 24, 
            bigSpacing: 32
        ),
        paddings: .init(
            topImage: 20,
            horizontal: 20,
            vertical: 12,
            bottom: 40
        ),
        image: .infoCircle
    )
}
