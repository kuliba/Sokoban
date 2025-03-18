//
//  ImageViewFactoryPreview.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Combine
import SwiftUI

extension ImageViewFactory {
    
    static let `default`: Self = .init(
        makeBannerImageView: {
            switch $0 {
            case "1":
                return  .init(
                    image: .bolt,
                    publisher: Just(.bolt).eraseToAnyPublisher()
                )
            default:
                return .init(
                    image: .flag,
                    publisher: Just(.flag).eraseToAnyPublisher()
                )
            }}
    )
}

extension Image {
    
    static let bolt: Self = .init(systemName: "bolt")
    static let flag: Self = .init(systemName: "flag")
}
