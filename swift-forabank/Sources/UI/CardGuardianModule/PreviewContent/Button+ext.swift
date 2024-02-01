//
//  Button+ext.swift
//  
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import Foundation

extension CardGuardianState._Button {
    
    static let one: Self = .init(event: .toggleLock, title: "One", iconType: .toggleLock, subtitle: "subtitle")
    static let two: Self = .init(event: .toggleLock, title: "Two", iconType: .changePin, subtitle: "subtitle")
    static let three: Self = .init(event: .toggleLock, title: "Three", iconType: .showOnMain, subtitle: "Карта не будет отображаться  на главном экране")
}

extension Array where Element == CardGuardianState._Button {
    
    static let preview: Self = [.one, .two, .three]
}
