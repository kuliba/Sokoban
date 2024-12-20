//
//  GetCollateralLandingConfig+BottomSheet.swift
//
//
//  Created by Valentin Ozerov on 16.12.2024.
//

import Foundation
import SwiftUI

extension GetCollateralLandingConfig {
    
    struct BottomSheet {
        
        let font: FontConfig
        let layouts: Layouts
        let radioButton: RadioButton
        let icon: Icon
        let divider: Divider

        struct Layouts {

            let spacing: CGFloat
            let scrollThreshold: UInt
            let sheetTopOffset: CGFloat
            let sheetBottomOffset: CGFloat
            let cellHeightCompensation: CGFloat
        }
        
        struct RadioButton {
                        
            let layouts: Layouts
            let paddings: Paddings
            let colors: Colors

            struct Layouts {
                
                let size: CGSize
                let cellHeigh: CGFloat
                let lineWidth: CGFloat
                let ringDiameter: CGFloat
                let circleDiameter: CGFloat
            }
            
            struct Paddings {
                
                let horizontal: CGFloat
                let vertical: CGFloat
            }
            
            struct Colors {
                
                let unselected: Color
                let selected: Color
            }
        }
        
        struct Icon {
            
            let size: CGSize
            let horizontalPadding: CGFloat
            let verticalPadding: CGFloat
            let cellHeigh: CGFloat
        }
        
        struct Divider {
            
            let leadingPadding: CGFloat
            let trailingPadding: CGFloat
        }
    }
}

extension GetCollateralLandingConfig.BottomSheet {
    
    static let `default` = Self(
        font: .init(Font.system(size: 16)),
        layouts: .init(
            spacing: 8,
            scrollThreshold: 6,
            sheetTopOffset: 100,
            sheetBottomOffset: 20,
            cellHeightCompensation: 8
        ),
        radioButton: .init(
            layouts: .init(
                size: .init(width: 24, height: 24),
                cellHeigh: 50,
                lineWidth: 1.25,
                ringDiameter: 20,
                circleDiameter: 10
            ),
            paddings: .init(
                horizontal: 18,
                vertical: 15
            ),
            colors: .init(
                unselected: .unselected,
                selected: .red
            )
        ),
        icon: .init(
            size: .init(width: 40, height: 40),
            horizontalPadding: 20,
            verticalPadding: 8,
            cellHeigh: 56
        ),
        divider: .init(
            leadingPadding: 55,
            trailingPadding: 15
        )
    )
}
