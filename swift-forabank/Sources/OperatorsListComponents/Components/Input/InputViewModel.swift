//
//  InputViewModel.swift
//
//
//  Created by Дмитрий Савушкин on 01.03.2024.
//

import Foundation
import SwiftUI

struct InputViewModel {
    
    let icon: Icon
    let image: Image
    
    let title: String
    let placeholder: String
    let hint: String?
    
    init(
        icon: Icon,
        image: Image,
        title: String,
        placeholder: String,
        hint: String?
    ) {
        self.icon = icon
        self.image = image
        self.title = title
        self.placeholder = placeholder
        self.hint = hint
    }
    
    enum Icon {
        
        case small
        case large
    }
}
