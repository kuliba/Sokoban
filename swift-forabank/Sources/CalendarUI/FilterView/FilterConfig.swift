//
//  FilterConfig.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation
import SwiftUI

struct FilterConfig {
    
    let button: ButtonConfig
    
    struct ButtonConfig {
        
        let selectBackgroundColor: Color
        let notSelectedBackgroundColor: Color
        
        let selectForegroundColor: Color
        let notSelectForegroundColor: Color
    }
}
