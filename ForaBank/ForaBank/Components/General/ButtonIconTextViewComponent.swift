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
        let icon: Icon
        let title: Title
        let orientation: Orientation
        let action: () -> Void
        var isActive: Bool = true
        
        struct Icon {
            
            let image: Image
            var style: Style = .color(.iconBlack)
            let background: Background
            
            enum Style {
                
                case original
                case color(Color)
            }
            
            enum Background {
                
                case circleSmall
                case circle
                case square
            }
        }
        
        struct Title {
            
            let text: String
            var color: Color = .textSecondary
            var style: Style = .normal
            
            enum Style {
                
                case normal
                case bold
            }
        }
        
        enum Orientation {
            
            case vertical
            case horizontal
        }

        init(id: UUID = UUID(), icon: ButtonIconTextView.ViewModel.Icon, title: ButtonIconTextView.ViewModel.Title, orientation: ButtonIconTextView.ViewModel.Orientation, action: @escaping () -> Void, isActive: Bool = true) {
            self.id = id
            self.icon = icon
            self.title = title
            self.orientation = orientation
            self.action = action
            self.isActive = isActive
        }

        static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
            
            lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct ButtonIconTextView: View {
    
    var viewModel: ViewModel
    
    var titleFont: Font {
        
        switch viewModel.title.style {
        case .normal: return .textBodySR12160()
        case .bold: return .textH4M16240()
        }
    }
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
            switch viewModel.orientation {
            case .vertical:

                VStack {
                    
                    IconView(viewModel: viewModel.icon)
                    
                    Text(viewModel.title.text)
                        .font(titleFont)
                        .foregroundColor(viewModel.title.color)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 75)
                }
                
            case .horizontal:

                if viewModel.isActive {
                    
                    HStack(spacing: 16) {
                        
                        IconView(viewModel: viewModel.icon)
                        
                        Text(viewModel.title.text)
                            .font(titleFont)
                            .foregroundColor(viewModel.title.color)
                            .multilineTextAlignment(.center)
                            
                    }
                } else {
                    
                    HStack(spacing: 16) {
                        
                        IconView(viewModel: viewModel.icon)
                        
                        Text(viewModel.title.text)
                            .font(titleFont)
                            .foregroundColor(viewModel.title.color)
                            .multilineTextAlignment(.center)
                    }.opacity(0.6)
                }
            }
            
        }.buttonStyle(PushButtonStyle())
        .disabled(!viewModel.isActive)
    }
}

extension ButtonIconTextView {
    
    struct IconView: View {
        
        let viewModel: ButtonIconTextView.ViewModel.Icon
        
        var side: CGFloat {
            
            switch viewModel.background {
            case .circleSmall: return 40
            case .circle: return 56
            case .square: return 48
            }
        }
        
        var body: some View {
            
            switch viewModel.style {
            case .original:
                viewModel.image
                    .renderingMode(.original)
                    .background(ButtonIconTextView.IconBackgroundView(viewModel: viewModel.background))
                    .frame(width: side, height: side)
                
            case .color(let color):
                viewModel.image
                    .renderingMode(.template)
                    .foregroundColor(color)
                    .background(ButtonIconTextView.IconBackgroundView(viewModel: viewModel.background))
                    .frame(width: side, height: side)
            }
        }
    }
    
    struct IconBackgroundView: View {
        
        let viewModel: ButtonIconTextView.ViewModel.Icon.Background
        
        var body: some View {
            
            switch viewModel {
            case .circle:
                Circle()
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(width: 56, height: 56)
                
            case .square:
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(width: 48, height: 48)
                
            case .circleSmall:
                Circle()
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(width: 40, height: 40)
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

            ButtonIconTextView(viewModel: .horizontalCircleBold)
                .previewLayout(.fixed(width: 375, height: 200))

            ButtonIconTextView(viewModel: .horizontalCircleBoldOriginal)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension ButtonIconTextView.ViewModel {
    
    static let telephoneTranslation = ButtonIconTextView.ViewModel(icon: .init(image: .ic24Smartphone, background: .circle), title: .init(text: "Перевод по телефону"), orientation: .vertical, action: {})
    
    static let qrPayment = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .circle), title: .init(text: "Оплата по QR"), orientation: .vertical, action: {})

    static let templates = ButtonIconTextView.ViewModel(icon: .init(image: .ic24Star, background: .circle), title: .init(text:  "Шаблоны"), orientation: .vertical, action: {})
    
    static let verticalSquare = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .square), title: .init(text: "Оплата по QR"), orientation: .vertical, action: {})

    static let horizontalSquare = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .square), title: .init(text: "Оплата по QR"), orientation: .horizontal, action: {})

    static let horizontalCircle = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .circle), title: .init(text: "Оплата по QR"), orientation: .horizontal, action: {})
    
    static let horizontalCircleBold = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .circle), title: .init(text: "Оплата по QR", style: .bold), orientation: .horizontal, action: {})
    
    static let horizontalCircleBoldOriginal = ButtonIconTextView.ViewModel(icon: .init(image: .ic40SBP, style: .original, background: .circle), title: .init(text: "С моего счета в другом банке", style: .bold), orientation: .horizontal, action: {})
}
