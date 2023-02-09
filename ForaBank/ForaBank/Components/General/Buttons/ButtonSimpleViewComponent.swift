//
//  PaymentsParameterPaymentButtonViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ButtonSimpleView {
    
    class ViewModel: ObservableObject, Identifiable {
        
        let id = UUID()
        @Published var title: String
        @Published var style: ButtonStyle
        let action: () -> Void

        internal init(title: String, style: ButtonStyle, action: @escaping () -> Void) {

            self.title = title
            self.action = action
            self.style = style
        }
        
        enum ButtonStyle {
            
            case red
            case gray
            case inactive
            
            var backgroundColor: Color {
                switch self {
                    
                case .red:      return .buttonPrimary
                case .gray:     return .buttonSecondary
                case .inactive: return .buttonPrimaryDisabled
                }
            }
            
            var foregroundColor: Color {
                switch self {
                    
                case .red:      return .textWhite
                case .gray:     return .textSecondary
                case .inactive: return .textWhite
                }
            }
        }
    }
}

//MARK: - View

struct ButtonSimpleView: View {
    
    @ObservedObject var viewModel: ButtonSimpleView.ViewModel
    
    var body: some View {
        
        switch viewModel.style {
            
        case .inactive:
            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(ViewModel.ButtonStyle.inactive.backgroundColor)
                
                Text(viewModel.title)
                    .font(.buttonLargeSB16180())
                    .foregroundColor(ViewModel.ButtonStyle.inactive.foregroundColor)
            }
            
        default :
            Button {
                
                viewModel.action()
                
            } label: {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(viewModel.style.backgroundColor)
                    
                    Text(viewModel.title)
                        .font(.buttonLargeSB16180())
                        .foregroundColor(viewModel.style.foregroundColor)
                }
            }
        }
    }
}

//MARK: - Preview

struct ButtonSimpleView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonSimpleView(viewModel: .init(title: "Оплатить", style: .inactive, action: {} ))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "Оплатить", style: .red, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "Скопировать все", style: .gray, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
        }
    }
}
