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

    let makeIconView: MakeIconView
    
    public init(
        makeIconView: @escaping MakeIconView
    ) {
        self.makeIconView = makeIconView
    }
}

public extension ImageViewFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
}

extension ImageViewFactory {
    
    static let `default`: Self = .init(
        makeIconView: { _ in 
            return  .init(
                image: .bolt,
                publisher: Just(.bolt).eraseToAnyPublisher()
            )
        }
    )
}

extension Image {
    
    static let bolt: Self = .init(systemName: "bolt")
}
