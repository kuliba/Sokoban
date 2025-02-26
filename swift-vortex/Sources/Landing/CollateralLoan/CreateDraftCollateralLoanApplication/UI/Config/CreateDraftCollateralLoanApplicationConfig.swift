//
//  CreateDraftCollateralLoanApplicationConfig.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import SwiftUI
import UIPrimitives
import InputComponent

public struct CreateDraftCollateralLoanApplicationConfig {
        
    public let fonts: Fonts
    public let colors: Colors
    public let layouts: Layouts
    public let icons: Icons
    public let elements: Elements
    
    public struct Elements {
        
        public let header: Header
        public let amount: Amount
        public let period: Period
        public let percent: Percent
        public let city: City
        public let otp: OTP
        public let consent: Consent
        public let button: Button
        public let result: Result
        
        public init(
            header: Header,
            amount: Amount,
            period: Period,
            percent: Percent,
            city: City,
            otp: OTP,
            consent: Consent,
            button: Button,
            result: Result
        ) {
            self.header = header
            self.amount = amount
            self.period = period
            self.percent = percent
            self.city = city
            self.otp = otp
            self.consent = consent
            self.button = button
            self.result = result
        }
    }
    
    public struct Icons {
        
        public let selectedItem: Image
        public let unselectedItem: Image
        
        public init(
            selectedItem: Image,
            unselectedItem: Image
        ) {
            self.selectedItem = selectedItem
            self.unselectedItem = unselectedItem
        }
    }
    
    public struct Fonts {
        
        let title: TextConfig
        let value: TextConfig
        
        public init(title: TextConfig, value: TextConfig) {

            self.title = title
            self.value = value
        }
    }
    
    public struct Colors {
        
        public let background: Color
        public let selected: Color
        public let unselected: Color

        public init(
            background: Color,
            selected: Color,
            unselected: Color
        ) {
            self.background = background
            self.selected = selected
            self.unselected = unselected
        }
    }
    
    public struct Layouts {
        
        public let iconSize: CGSize
        public let cornerRadius: CGFloat
        public let contentHorizontalSpacing: CGFloat
        public let contentVerticalSpacing: CGFloat
        public let shimmeringHeight: CGFloat
        public let paddings: Paddings

        public init(
            iconSize: CGSize,
            cornerRadius: CGFloat,
            contentHorizontalSpacing: CGFloat,
            contentVerticalSpacing: CGFloat,
            shimmeringHeight: CGFloat,
            paddings: Paddings
        ) {
            self.iconSize = iconSize
            self.cornerRadius = cornerRadius
            self.contentHorizontalSpacing = contentHorizontalSpacing
            self.contentVerticalSpacing = contentVerticalSpacing
            self.shimmeringHeight = shimmeringHeight
            self.paddings = paddings
        }
        
        public struct Paddings {
            
            public let stack: EdgeInsets
            public let contentStack: EdgeInsets

            public init(stack: EdgeInsets, contentStack: EdgeInsets) {
                
                self.stack = stack
                self.contentStack = contentStack
            }
        }
    }
    
    public struct FontConfig {
        
        public let font: Font
        public let foreground: Color
        public let background: Color
        
        public init(
            _ font: Font,
            foreground: Color = .black,
            background: Color = .white
        ) {
            self.font = font
            self.foreground = foreground
            self.background = background
        }
    }
    
    public struct ChevronViewConfig: Equatable {
        
        public let color: Color
        public let image: Image
        public let size: CGFloat
        
        public init(color: Color, image: Image, size: CGFloat) {
            self.color = color
            self.image = image
            self.size = size
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig {
    
    public static let `default` = Self(
        fonts: .init(
            title: .init(textFont: Font.system(size: 14), textColor: .title),
            value: .init(textFont: Font.system(size: 16), textColor: .primary)
        ),
        colors: .init(
            background: .background,
            selected: .red,
            unselected: .secondary
        ),
        layouts: .init(
            iconSize: .init(width: 27, height: 27),
            cornerRadius: 12,
            contentHorizontalSpacing: 12,
            contentVerticalSpacing: 4,
            shimmeringHeight: 150,
            paddings: .init(
                stack: .init(
                    top: 10,
                    leading: 15,
                    bottom: 0,
                    trailing: 12
                ),
                contentStack: .init(
                    top: 13,
                    leading: 12,
                    bottom: 13,
                    trailing: 16
                )
            )
        ),
        icons: .init(
            selectedItem: Image(systemName: "record.circle"),
            unselectedItem: Image(systemName: "circle")
        ),
        elements: .init(
            header: .preview,
            amount: .preview,
            period: .preview,
            percent: .preview,
            city: .preview,
            otp: .preview,
            consent: .preview,
            button: .preview,
            result: .preview
        )
    )
}

private extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let background: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let shimmering: Self = .init(red: 0.77, green: 0.77, blue: 0.77)
}

extension CreateDraftCollateralLoanApplicationConfig {
    
    var shimmeringGradient: Gradient { .init(colors: [.shimmering, .clear]) }
}
