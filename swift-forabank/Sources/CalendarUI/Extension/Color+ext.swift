//
//  Color+ext.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation
import SwiftUI

extension Color {
    
    static let todayColorLabel: Color = {
    
        Color.red
    }()
    
    static let todayColorBackground: Color = {
    
        Color.gray
    }()
    
    static let selectedLabel: Color = {
    
        Color.white
    }()
    
    static let selectedBackground: Color = {
    
        Color.black
    }()
    
    
    static let backgroundPrimary: Color = {
        Color(UIColor.black)
    }()
    
    static let backgroundSecondary: Color = {
        Color(UIColor.secondarySystemBackground)
    }()

    static let onBackgroundPrimary: Color = {
        Color(UIColor.label)
    }()
    
    static let onBackgroundSecondary: Color = {
        Color(UIColor.secondaryLabel)
    }()
}
