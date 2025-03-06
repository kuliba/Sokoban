//
//  ButtonIconTextView.swift
//  Vortex
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import SwiftUI

// MARK: - ViewModel

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
            var backgroundColor: Color = .mainColorsGrayLightest
            var badge: Badge? = nil
            
            enum Style {
                
                case original
                case color(Color)
            }
            
            enum Background {
                
                case circleSmall
                case circle
                case square
            }
            
            struct Badge {
                
                let text: Text
                var backgroundColor: Color
                var textColor: Color
                
                struct Text {
                    
                    let title: String
                    let font: Font
                    let fontWeight: Font.Weight
                }
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
    }
}

// MARK: - View

struct ButtonIconTextView: View {
    
    var viewModel: ViewModel
    
    var titleFont: Font {
        
        switch viewModel.title.style {
        case .normal: return .textBodySR12160()
        case .bold:   return .textH4M16240()
        }
    }
    
    var body: some View {
        
        Button(action: viewModel.action, label: label)
            .buttonStyle(PushButtonStyle())
            .disabled(!viewModel.isActive)
    }
    
    @ViewBuilder
    private func label() -> some View {
        
        switch viewModel.orientation {
        case .vertical:
            
            VStack {
                
                iconView()
                
                titleView(multilineTextAlignment: .center)
                    .frame(maxWidth: 75)
            }
            
        case .horizontal:
            
            HStack(spacing: 16) {
                
                iconView()
                
                titleView(multilineTextAlignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(viewModel.isActive ? 1 : 0.6)
        }
    }
    
    private func iconView() -> some View {
        
        IconView(viewModel: viewModel.icon)
    }
    
    private func titleView(
        multilineTextAlignment alignment: TextAlignment
    ) -> some View {
        
        Text(viewModel.title.text)
            .font(titleFont)
            .foregroundColor(viewModel.title.color)
            .multilineTextAlignment(alignment)
    }
}

extension ButtonIconTextView {
    
    struct IconView: View {
        
        let viewModel: ButtonIconTextView.ViewModel.Icon
        
        var side: CGFloat {
            
            switch viewModel.background {
            case .circleSmall: return 40
            case .circle:      return 56
            case .square:      return 48
            }
        }
        
        var badgeOffsetX: CGFloat {
            
            switch viewModel.background {
            case .circleSmall: return 10.7
            case .circle:      return 15
            case .square:      return 12.9
            }
        }
        
        var badgeOffsetY: CGFloat {
            
            switch viewModel.background {
            case .circleSmall: return -8.6
            case .circle:      return -12
            case .square:      return -10.3
            }
        }
        
        var body: some View {
            
            ZStack {
                
                ButtonIconTextView.IconBackgroundView(viewModel: viewModel)
                
                switch viewModel.style {
                case .original:
                    viewModel.image
                        .renderingMode(.original)
                    
                case .color(let color):
                    viewModel.image
                        .renderingMode(.template)
                        .foregroundColor(color)
                }
                
                if let badge = viewModel.badge {
                    
                    ZStack {
                        
                        CornerBadgeShape()
                            .fill(badge.backgroundColor)
                        
                        Text(badge.text.title)
                            .font(badge.text.font)
                            .fontWeight(badge.text.fontWeight)
                            .foregroundColor(badge.textColor)
                            .rotationEffect(.degrees(45))
                            .offset(x: badgeOffsetX, y: badgeOffsetY)
                    }
                    .clipShape(Circle())
                }
            }
            .frame(width: side, height: side)
        }
    }
    
    struct IconBackgroundView: View {
        
        let viewModel: ButtonIconTextView.ViewModel.Icon
        
        var body: some View {
            
            switch viewModel.background {
            case .circle:
                Circle()
                    .foregroundColor(viewModel.backgroundColor)
                    .frame(width: 56, height: 56)
                
            case .square:
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(viewModel.backgroundColor)
                    .frame(width: 48, height: 48)
                
            case .circleSmall:
                Circle()
                    .foregroundColor(viewModel.backgroundColor)
                    .frame(width: 40, height: 40)
            }
        }
    }
}

// MARK: - Preview

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

struct CornerBadgeShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        let size = rect.size
        
        path.move(to: CGPoint(x: size.width * 0.33, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height * 0.6))
        path.addLine(to: CGPoint(x: size.width * 1.25, y: size.height))
        
        return path
    }
}

// MARK: - Preview Content

extension ButtonIconTextView.ViewModel {
    
    static let telephoneTranslation = ButtonIconTextView.ViewModel(icon: .init(image: .ic24Smartphone, background: .circle), title: .init(text: "Перевод по телефону"), orientation: .vertical, action: {})
    
    static let qrPayment = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .circle), title: .init(text: "Оплата по QR"), orientation: .vertical, action: {})
    
    static let templates = ButtonIconTextView.ViewModel(icon: .init(image: .ic24Star, background: .circle), title: .init(text:  "Шаблоны"), orientation: .vertical, action: {})
    
    static let verticalSquare = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .square), title: .init(text: "Оплата по QR"), orientation: .vertical, action: {})
    
    static let horizontalSquare = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .square), title: .init(text: "Оплата по QR"), orientation: .horizontal, action: {})
    
    static let horizontalCircle = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .circle), title: .init(text: "Оплата по QR"), orientation: .horizontal, action: {})
    
    static let horizontalCircleBold = ButtonIconTextView.ViewModel(icon: .init(image: .ic24BarcodeScanner2, background: .circle), title: .init(text: "Оплата по QR", style: .bold), orientation: .horizontal, action: {})
    
    static let horizontalCircleBoldOriginal = ButtonIconTextView.ViewModel(icon: .init(image: .ic40Sbp, style: .original, background: .circle), title: .init(text: "С моего счета в другом банке", style: .bold), orientation: .horizontal, action: {})
}
