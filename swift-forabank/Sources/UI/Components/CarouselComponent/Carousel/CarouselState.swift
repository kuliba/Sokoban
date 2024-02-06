//
//  CarouselState.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import Foundation

public enum CarouselState: Hashable {
    
    case initial(Configuration)
}

public extension CarouselState {
    
    struct Configuration: Hashable {
        
        let appearance: Appearance
        let style: Style

        public init(
            appearance: Appearance = .main,
            style: Style = .regular
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
            
            case regular
            case small
            
            var itemSpacing: CGFloat {
                
                switch self {
                case .regular, .small:
                    return 13
                }
            }
        }
    }
}
