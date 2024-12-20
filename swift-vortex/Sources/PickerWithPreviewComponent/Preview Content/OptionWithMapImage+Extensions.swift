//
//  OptionWithMapImage+Extensions.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import Foundation
import SwiftUI

public extension OptionWithMapImage {
    
    static let oneWithHtml: Self = .init(
        id: 1,
        value: "1",
        mapImage: .placeholder,
        title: "<h3 style=\"font-family: 'Inter', sans-serif; color: #1C1C1C; font-style: normal; font-weight: normal; line-height: 20px; font-size: 16px\">4От внешней стороны <span style=\"color: #68AD45; \"><strong>Садового кольца</strong></span> до границ г. Москвы</h3>"
    )
    static let twoWithHtml: Self = .init(
        id: 2,
        value: "2",
        mapImage: .image(.init(systemName: "paperplane")),
        title: "<h3 style=\"font-family: 'Inter', sans-serif; color: #1C1C1C; font-style: normal; font-weight: normal; line-height: 20px; font-size: 16px\">От внешней стороны<span style=\"color: #68AD45;\"><strong> Бульварного кольца</strong></span> до границ г. Москвы</h3>"
    )
    static let threeWithHtml: Self = .init(
        id: 3,
        value: "3",
        mapImage: .image(.init(systemName: "airplane")),
        title: "тестовое поле (не html строка)"
    )
    static let fourWithHtml: Self = .init(
        id: 4,
        value: "4",
        mapImage:
                .image(.init(systemName: "airplane")), title: "тестовое поле (не html строка)")
}

public extension CheckUncheckImages {
    
    static let `default`: Self = .init(
        checkedImage: .checkImage,
        uncheckedImage: .unCheckImage
    )
}

public extension Image {
    
    static let checkImage: Self = .init(systemName: "checkmark.circle.fill")
    static let unCheckImage: Self = .init(systemName: "checkmark.circle")
}
