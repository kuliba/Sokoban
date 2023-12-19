//
//  Image+ImageData.swift
//  
//
//  Created by Дмитрий Савушкин on 18.11.2023.
//

import Foundation
import SwiftUI

extension Image {
    
    init(data: Data?, fallback: UIImage = .checkmark) {
        
        let uiImage: UIImage = data.map { .init(data: $0) ?? fallback } ?? fallback
        self = .init(uiImage: uiImage)
    }
    
    init(imageData: ImageData, fallback: UIImage = .checkmark) {
        
        switch imageData {
        case let .data(data):
            self.init(data: data, fallback: fallback)
            
        case let .named(name):
            self.init(name)
            
        case let .systemName(systemName):
            self.init(systemName: systemName)
        }
    }
}
