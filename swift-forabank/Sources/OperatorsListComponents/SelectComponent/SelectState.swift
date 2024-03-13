//
//  SelectState.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI

enum SelectState {
    
    case collapsed
    case expanded(options: [Option])
    case selectedOption(option: Option)
    
    struct Option {
        
        let id: String
        
        let title: String
        let icon: Image
        let backgroundIcon: Color
        
    }
}
