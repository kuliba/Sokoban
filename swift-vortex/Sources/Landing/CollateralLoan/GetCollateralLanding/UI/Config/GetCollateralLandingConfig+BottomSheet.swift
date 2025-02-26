//
//  GetCollateralLandingConfig+BottomSheet.swift
//
//
//  Created by Valentin Ozerov on 16.12.2024.
//

import Foundation
import SwiftUI

extension GetCollateralLandingConfig {
    
    public struct BottomSheet {
        
        public let font: FontConfig
        public let layouts: Layouts
        public let radioButton: RadioButton
        public let icon: Icon
        public let divider: Divider

        public init(
            font: FontConfig,
            layouts: Layouts,
            radioButton: RadioButton,
            icon: Icon,
            divider: Divider
        ) {
            self.font = font
            self.layouts = layouts
            self.radioButton = radioButton
            self.icon = icon
            self.divider = divider
        }
        
        public struct Layouts {

            public let spacing: CGFloat
            public let scrollThreshold: UInt
            public let sheetTopOffset: CGFloat
            public let sheetBottomOffset: CGFloat
            public let cellHeightCompensation: CGFloat
            
            public init(
                spacing: CGFloat,
                scrollThreshold: UInt,
                sheetTopOffset: CGFloat,
                sheetBottomOffset: CGFloat,
                cellHeightCompensation: CGFloat
            ) {
                self.spacing = spacing
                self.scrollThreshold = scrollThreshold
                self.sheetTopOffset = sheetTopOffset
                self.sheetBottomOffset = sheetBottomOffset
                self.cellHeightCompensation = cellHeightCompensation
            }
        }
        
        public struct RadioButton {
                        
            public let layouts: Layouts
            public let paddings: Paddings
            public let colors: Colors

            public init(
                layouts: Layouts,
                paddings: Paddings,
                colors: Colors
            ) {
                self.layouts = layouts
                self.paddings = paddings
                self.colors = colors
            }
            
            public struct Layouts {
                
                public let size: CGSize
                public let cellHeigh: CGFloat
                public let lineWidth: CGFloat
                public let ringDiameter: CGFloat
                public let circleDiameter: CGFloat
                
                public init(
                    size: CGSize,
                    cellHeigh: CGFloat,
                    lineWidth: CGFloat,
                    ringDiameter: CGFloat,
                    circleDiameter: CGFloat
                ) {
                    self.size = size
                    self.cellHeigh = cellHeigh
                    self.lineWidth = lineWidth
                    self.ringDiameter = ringDiameter
                    self.circleDiameter = circleDiameter
                }
            }
            
            public struct Paddings {
                
                public let horizontal: CGFloat
                public let vertical: CGFloat
                
                public init(
                    horizontal: CGFloat,
                    vertical: CGFloat
                ) {
                    self.horizontal = horizontal
                    self.vertical = vertical
                }
            }
            
            public struct Colors {
                
                public let unselected: Color
                public let selected: Color
                
                public init(
                    unselected: Color,
                    selected: Color
                ) {
                    self.unselected = unselected
                    self.selected = selected
                }
            }
        }
        
        public struct Icon {
            
            public let size: CGSize
            public let horizontalPadding: CGFloat
            public let verticalPadding: CGFloat
            public let cellHeigh: CGFloat
            
            public init(
                size: CGSize,
                horizontalPadding: CGFloat,
                verticalPadding: CGFloat,
                cellHeigh: CGFloat
            ) {
                self.size = size
                self.horizontalPadding = horizontalPadding
                self.verticalPadding = verticalPadding
                self.cellHeigh = cellHeigh
            }
        }
        
        public struct Divider {
            
            public let leadingPadding: CGFloat
            public let trailingPadding: CGFloat
            
            public init(
                leadingPadding: CGFloat,
                trailingPadding: CGFloat
            ) {
                self.leadingPadding = leadingPadding
                self.trailingPadding = trailingPadding
            }
        }
    }
}

extension GetCollateralLandingConfig.BottomSheet {
    
    static let preview = Self(
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
