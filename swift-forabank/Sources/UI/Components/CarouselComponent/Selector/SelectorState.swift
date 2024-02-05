//
//  SelectorState.swift
//  
//
//  Created by Disman Dmitry on 02.02.2024.
//

import Foundation

public enum SelectorState: Hashable {
    
    case initial(Configuration)
}

public extension SelectorState {
    
    struct Configuration: Hashable {
        
        let appearance: Appearance
        let style: Style

        public init(
            appearance: Appearance = .main,
            style: Style = .template
        ) {
            self.appearance = appearance
            self.style = style
        }
        
        public enum Appearance {
            
            case main
            case profile
            case myProducts
            case payments
        }
        
        public enum Style {
            
            case template
            case products
            case productsSmall
            
            var itemSpacing: CGFloat {
                
                switch self {
                case .template:
                    return 8
                case .products, .productsSmall:
                    return 12
                }
            }
        }
    }
}
