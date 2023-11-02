//
//  Input.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import Foundation
//import TextFieldComponent

extension Operation.Parameter {
    
    struct Input: Hashable {
        
        let value: String
        let title: String
        let icon: String
    }
}
