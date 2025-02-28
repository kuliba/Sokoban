//
//  ImageViewFactory.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2025.
//

import Foundation
import Combine
import SwiftUI
import UIPrimitives

public struct ImageViewFactory {
    
    let makeBannerImageView: MakeBannerImageView
    
    public init(
        makeBannerImageView: @escaping MakeBannerImageView
    ) {
        self.makeBannerImageView = makeBannerImageView
    }
}

public extension ImageViewFactory {
    
    typealias MakeBannerImageView = (String) -> UIPrimitives.AsyncImage
}

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

