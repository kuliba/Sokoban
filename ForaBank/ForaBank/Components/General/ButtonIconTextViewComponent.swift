//
//  ButtonIconTextView.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ButtonIconTextView {
    
    struct ViewModel: Identifiable {
        
        let id: UUID
        let icon: Image
        let title: String
        let orientation: Orientation
        let appearance: Appearance
        let iconColor: Color
        let action: () -> Void
        
        enum Orientation {
            
            case vertical
            case horizontal
        }
        
        enum Appearance {
            
            case circle
            case square
        }
        
        internal init(id: UUID = UUID(), icon: Image, title: String, orientation: Orientation, appearance: Appearance, iconColor: Color = .iconBlack, action: @escaping () -> Void) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.orientation = orientation
            self.appearance = appearance
            self.iconColor = iconColor
            self.action = action
        }
        
        static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
            
            lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct ButtonIconTextView: View {
    
    var viewModel: ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
            switch viewModel.orientation {
            case .vertical:

                VStack {
                    
                   IconView(viewModel: viewModel)
                    
                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 75)
                }
                
            case .horizontal:

                HStack(spacing: 16) {
                    
                   IconView(viewModel: viewModel)
                    
                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        
                }
            }
            
        }.buttonStyle(PushButtonStyle())
    }
}

extension ButtonIconTextView {
    
    struct IconView: View {
        
        let viewModel: ButtonIconTextView.ViewModel
        
        var body: some View {
            
            ZStack {
                
                switch viewModel.appearance {
                case .circle:
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 56, height: 56)
                    
                case .square:
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 48, height: 48)
                }
                
                viewModel.icon
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(viewModel.iconColor)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

//MARK: - Preview

struct FastOperationButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            ButtonIconTextView(viewModel: .telephoneTranslation)
                .previewLayout(.fixed(width: 375, height: 200))
            
            ButtonIconTextView(viewModel: .verticalSquare)
                .previewLayout(.fixed(width: 375, height: 200))
            
            ButtonIconTextView(viewModel: .horizontalSquare)
                .previewLayout(.fixed(width: 375, height: 200))
            
            ButtonIconTextView(viewModel: .horizontalCircle)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension ButtonIconTextView.ViewModel {
    
    static let telephoneTranslation =  ButtonIconTextView.ViewModel.init(icon: .ic24Smartphone, title: "Перевод по телефону", orientation: .vertical, appearance: .circle, action: {})
    
    static let qrPayment = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2, title: "Оплата по QR", orientation: .vertical, appearance: .circle, action: {})
    
    static let templates = ButtonIconTextView.ViewModel.init(icon: .ic24Star, title: "Шаблоны", orientation: .vertical, appearance: .circle, action: {})
    
    static let verticalSquare = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2, title: "Оплата по QR", orientation: .vertical, appearance: .square, action: {})
    
    static let horizontalSquare = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2, title: "Оплата по QR", orientation: .horizontal, appearance: .square,action: {})

    static let horizontalCircle = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2, title: "Оплата по QR", orientation: .horizontal, appearance: .circle, action: {})
}
