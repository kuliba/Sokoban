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
        makeIconView: {
            switch $0 {
    case "1":
        return  .init(
            image: .bolt,
            publisher: Just(.bolt).eraseToAnyPublisher()
        )
        
    case "2":
        return  .init(
            image: .shield,
            publisher: Just(.shield).eraseToAnyPublisher()
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
    static let percent: Self = .init(systemName: "percent")
    static let shield: Self = .init(systemName: "shield")
    static let flag: Self = .init(systemName: "flag")
}
