//
//  UtilityServicePickerState+preview.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Foundation

extension UtilityServicePickerState where Icon == String {
    
    static var preview: Self {
        
        .init(operator: .preview, services: .preview)
    }
}
