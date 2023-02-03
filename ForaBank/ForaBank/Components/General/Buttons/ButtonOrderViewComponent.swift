//
//  ButtonOrderViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.12.2022.
//

import SwiftUI

// MARK: - ViewModel

extension ButtonOrderView {
    
    class ViewModel: ObservableObject {
        
        @Published var title: String
        @Published var style: ButtonStyle
        
        let id: Int
        let action: (_ id: Int) -> Void
        
        init(_ id: Int, title: String, style: ButtonStyle, action: @escaping (_ id: Int) -> Void) {
            
            self.id = id
            self.title = title
            self.style = style
            self.action = action
        }
        
        enum ButtonStyle {
            
            case red
            case gray
            
            var backgroundColor: Color {
                
                switch self {
                case .red: return .mainColorsRed
                case .gray: return .buttonSecondary
                }
            }
            
            var textColor: Color {
                
                switch self {
                case .red: return .mainColorsWhite
                case .gray: return .textSecondary
                }
            }
        }
    }
}

extension ButtonOrderView.ViewModel {
    
    var backgroundColor: Color { style.backgroundColor }
    var textColor: Color { style.textColor }
}

// MARK: - View

struct ButtonOrderView: View {
    
    @ObservedObject var viewModel: ButtonOrderView.ViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.action(viewModel.id)
            
        } label: {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(viewModel.backgroundColor)
                
                Text(viewModel.title)
                    .font(.buttonLargeSB16180())
                    .foregroundColor(viewModel.textColor)
            }
        }
    }
}

// MARK: - Preview

struct ButtonOrderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonOrderView(viewModel: .init(1, title: "Оплатить", style: .red, action: { _ in }))
            ButtonOrderView(viewModel: .init(2, title: "Скопировать все", style: .gray, action: { _ in }))
        }
        .previewLayout(.fixed(width: 375, height: 70))
        .padding(8)
    }
}
