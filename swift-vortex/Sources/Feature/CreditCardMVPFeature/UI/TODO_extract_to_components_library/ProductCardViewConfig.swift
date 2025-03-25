//
//  ProductCardViewConfig.swift
//
//
//  Created by Igor Malyarov on 25.03.2025.
//

import SwiftUI
import UIPrimitives

struct ProductCardViewConfig: Equatable {
    
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let edges: EdgeInsets
    let spacing: CGFloat
    let header: HeaderConfig
    let label: LabelConfig
}

extension ProductCardViewConfig {
    
    struct HeaderConfig: Equatable {
        
        let title: TextConfig
        let subtitle: TextConfig
        let spacing: CGFloat
    }
    
    struct LabelConfig: Equatable {
        
        let icon: IconConfig
        let option: OptionConfig
        let title: TitleConfig
        let spacing: CGFloat
    }
}

extension ProductCardViewConfig.LabelConfig {
    
    struct IconConfig: Equatable {
        
        let cornerRadius: CGFloat
        let shadow: ShadowConfig
        let size: CGSize
    }
    
    struct OptionConfig: Equatable {
        
        let icon: Image
        let iconColor: Color
        let iconSize: CGFloat
        let spacing: CGFloat
        let title: TextConfig
        let value: TextConfig
        let valueSpacing: CGFloat
    }
    
#warning("Remove")
    struct TitleConfig: Equatable {
        let spacing: CGFloat
    }
}

extension ProductCardViewConfig.LabelConfig.IconConfig {
    
    struct ShadowConfig: Equatable {
        
        let color: Color
        let offset: CGFloat
        let blur: CGFloat
        let size: CGSize
    }
}

