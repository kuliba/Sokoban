//
//  ImageViewFactory.swift
//
//
//  Created by Andryusina Nataly on 19.11.2024.
//

import Foundation
import Combine
import SwiftUI
import UIPrimitives

extension ListImageViewFactory {
    
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
    }},
        
        makeBannerImageView: {
            switch $0 {
    case "1":
        return  .init(
            image: .shield,
            publisher: Just(.shield).eraseToAnyPublisher()
        )
        
    case "2":
        return  .init(
            image: .bolt,
            publisher: Just(.bolt).eraseToAnyPublisher()
        )
        
    default:
        return .init(
            image: .percent,
            publisher: Just(.percent).eraseToAnyPublisher()
        )
    }})
}

extension Image {
    
    static let bolt: Self = .init(systemName: "bolt")
    static let percent: Self = .init(systemName: "percent")
    static let shield: Self = .init(systemName: "shield")
    static let flag: Self = .init(systemName: "flag")
}
