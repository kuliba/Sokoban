//
//  PreviewContent.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI

extension ClientInformListConfig.Colors {
    
    static let preview: Self = .init(

        grayGrabber: Color(red: 0.83, green: 0.83, blue: 0.83),
        grayBackground: Color(red: 0.97, green: 0.97, blue: 0.97)
    )
}

extension Image {
    
    static let clock: Self = .init(systemName: "clock")
    static let infoCircle: Self = .init(systemName: "info.circle")
}

extension ClientInformListConfig.Strings {
    
    static let preview: Self = .init(titlePlaceholder: "Информация")
}

@available(iOS 15, *)
extension ClientInformListDataState {
    
    static let preview: Self = ClientInformListDataState.multiple(.init(
        title: Label(image: .infoCircle, title: "Информация"),
        items: [
            Label(image: .clock, title: "Время работы изменилось на 13:00 - 15:00"),
            Label(image: .infoCircle, title: "Информация на главном портале обновилась")
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
            iconSize: 64,
            rowIconSize: 40,
            navBarHeight: 59,
            navBarMaxWidth: 48,
            grabberWidth: 48,
            grabberHeight: 5,
            grabberCornerRadius: 3,
            spacing: 24
        ),
        paddings: .init(
            topGrabber: 8,
            topImage: 20,
            horizontal: 20,
            vertical: 12
        ),
        image: .infoCircle,
        rowImage: .clock
    )
}
