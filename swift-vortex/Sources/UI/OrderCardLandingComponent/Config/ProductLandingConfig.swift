//
//  ProductLandingConfig.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import SharedConfigs
import SwiftUI

struct ProductLandingConfig {
    
    let background: Color
    let buttonsConfig: ButtonsConfig
    let conditionButtonConfig: ConditionButtonConfig
    let item: ItemConfig
    let imageCoverConfig: ImageCoverConfig
    let orderButtonConfig: OrderButtonConfig
    let title: TextConfig
    
    struct ButtonsConfig {
        
        let buttonsPadding: CGFloat
        let buttonsSpacing: CGFloat
        let buttonsHeight: CGFloat
    }
    
    struct ImageCoverConfig {
    
        let height: CGFloat
        let cornerRadius: CGFloat
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
    }
    
    struct OrderButtonConfig {
        
        let background: Color
        let cornerRadius: CGFloat
        let title: TitleConfig
    }
    
    struct ConditionButtonConfig {
        
        let icon: Image
        let spacing: CGFloat
        let frame: CGFloat
        let title: TitleConfig
    }
    
    struct ItemConfig {
        
        let circle: CGFloat
        let title: TextConfig
        let itemPadding: CGFloat
    }
}
