//
//  PaymentTemplatesSettings.swift
//  Vortex
//
//  Created by Dmitry Martynov on 10.07.2023.
//

import Foundation

struct PaymentTemplatesSettings: Codable {
    
    var style: TemplatesListViewModel.Style
    
    mutating func update(style: TemplatesListViewModel.Style) {
        
        self.style = style
    }
}
