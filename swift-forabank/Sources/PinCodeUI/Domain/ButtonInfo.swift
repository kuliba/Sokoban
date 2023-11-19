//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import SwiftUI

struct ButtonInfo: Identifiable {
    
    let id = UUID()
    let value: String
    let image: Image?
    let type: ButtonType

    enum ButtonType {
        
        case digit
        case delete
    }
}

extension ButtonInfo {
    
    static let key1: Self = .init(value: "1", image: nil, type: .digit)
    static let key2: Self = .init(value: "2", image: nil, type: .digit)
    static let key3: Self = .init(value: "3", image: nil, type: .digit)
    static let key4: Self = .init(value: "4", image: nil, type: .digit)
    static let key5: Self = .init(value: "5", image: nil, type: .digit)
    static let key6: Self = .init(value: "6", image: nil, type: .digit)
    static let key7: Self = .init(value: "7", image: nil, type: .digit)
    static let key8: Self = .init(value: "8", image: nil, type: .digit)
    static let key9: Self = .init(value: "9", image: nil, type: .digit)
    static let key0: Self = .init(value: "0", image: nil, type: .digit)
    static let deleteKey: Self = .init(value: "", image: Image(systemName: "delete.backward"), type: .delete)
}

extension Array where Element == ButtonInfo {
    
    static let keys123: Self = [.key1, .key2, .key3]
    static let keys456: Self = [.key4, .key5, .key6]
    static let keys789: Self = [.key7, .key8, .key9]
    static let keys0: Self = [.key0, .deleteKey]
}
