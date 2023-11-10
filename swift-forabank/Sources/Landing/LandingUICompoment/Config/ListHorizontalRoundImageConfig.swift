//
//  ListHorizontalRoundImageConfig.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

extension ListHorizontalRoundImageView {
    
    struct Config {
        
        let backgroundColor: Color
        let title: Title
        let subtitle: Subtitle
        let detail: Detail
        
        struct Title {
            
            let color: Color
            let font: Font
        }
        
        struct Subtitle {
            
            let color: Color
            let background: Color
            let font: Font
        }

        struct Detail {
            
            let color: Color
            let font: Font
        }
    }
}
