//
//  SberQRSelection.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 20.11.2023.
//

import Foundation

struct SberQRSelection: Hashable, Identifiable {
    
    typealias Completion = (String?) -> Void
    
    let id = UUID()
    let url: URL
    let completion: Completion
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        lhs.id == rhs.id && lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
        hasher.combine(url)
    }
}
