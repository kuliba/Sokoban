//
//  AccountCellButtonViewComponent.swift
//  Vortex
//
//  Created by Mikhail on 25.04.2022.
//

import SwiftUI

//MARK: - ViewModel

extension AccountCellButtonView {
    
    class ViewModel: AccountCellDefaultViewModel, ObservableObject {
        
        let button: ButtonView.ViewModel
        let style: Style
        
        internal init(icon: Image, content: String, title: String? = nil, button: ButtonView.ViewModel, style: Style) {
            
            self.button = button
            self.style = style
            super.init(id: UUID(), icon: icon, content: content, title: title)
        }
        
        enum Style {
            
            case rounded
            case regular
        }
    }
}

//MARK: - View

struct AccountCellButtonView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.button.action()
            
        } label: {
            
            HStack(spacing: 20) {
                
                switch viewModel.style {
                case .regular:
                    viewModel.icon
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                    
                case .rounded:
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.mainColorsGrayLightest)
                            .frame(width: 40, height: 40)
                        
                        viewModel.icon
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    if let placeholder = viewModel.title {
                        
                        Text(verbatim: placeholder)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                    }
                    
                    Text(verbatim: viewModel.content)
                        .font(.textH4M16240())
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if let icon = viewModel.button.icon {
                    
                    icon
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(height: 56, alignment: .leading)
    }
}


extension AccountCellButtonView {
    
    struct ButtonView: View {
        
        class ViewModel: ObservableObject {
            
            let icon: Image?
            let action: () -> Void
            
            internal init(icon: Image?, action: @escaping () -> Void) {
                
                self.icon = icon
                self.action = action
            }
        }
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
            Button {
                
                viewModel.action()
                
            } label: {
                
                viewModel.icon
                    .foregroundColor(.black)
            }
        }
    }
}

//MARK: - Preview

struct AccountCellButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            AccountCellButtonView(viewModel: .name)
                .previewLayout(.fixed(width: 375, height: 80))
            AccountCellButtonView(viewModel: .paymentSPF)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension AccountCellButtonView.ViewModel {
    
    static let name = AccountCellButtonView.ViewModel(
        icon: .ic24User,
        content: "Николай",
        title: "Имя",
        button: .init(icon: .ic24Edit2, action: {} ), style: .rounded
    )
    
    static let paymentSPF =  AccountCellButtonView.ViewModel(
        icon: Image("sbp-logo"),
        content: "Система быстрых платежей",
        button: .init(icon: .ic24ChevronRight, action: {} ), style: .rounded
    )
    
}
