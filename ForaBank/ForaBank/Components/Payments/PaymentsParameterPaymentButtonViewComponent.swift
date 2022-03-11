//
//  PaymentsParameterPaymentButtonViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ButtonSimpleView {
    
    class ViewModel: ObservableObject {
        
        let title: String
        @Published var isEnabled: Bool {
            didSet {
                print("ButtonSimpleView change", isEnabled)
            }
        }
        
        let action: () -> Void

        internal init(title: String, isEnabled: Bool, action: @escaping () -> Void) {

            self.title = title
            self.action = action
            self.isEnabled = isEnabled
        }
        
        internal init(buttonModel: PaymentsOperationViewModel.ContinueButtonViewModel) {

            self.title = buttonModel.title
            self.action = buttonModel.action
            self.isEnabled = buttonModel.isEnabled
        }
    }
}

//MARK: - View

struct ButtonSimpleView: View {
    
    @ObservedObject var viewModel: ButtonSimpleView.ViewModel
    
    var body: some View {
        
        if viewModel.isEnabled {
            
            Button {
                
                viewModel.action()
                
            } label: {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color(hex: "#FF3636"))
                    
                    Text(viewModel.title)
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color(hex: "#FFFFFF"))
                }
            }

        } else {

            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(hex: "#D3D3D3"))
                
                Text(viewModel.title)
                    .font(Font.custom("Inter-Regular", size: 16))
                    .foregroundColor(Color(hex: "#FFFFFF"))
            }
        }
    }
}

//MARK: - Preview

struct ButtonSimpleView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonSimpleView(viewModel: .init(title: "Оплатить", isEnabled: false, action: {} ))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "Перевести", isEnabled: false, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "Продолжить", isEnabled: false, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "Оплатить", isEnabled: true, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "На главную", isEnabled: true, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "Перевести", isEnabled: true, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(title: "Продолжить", isEnabled: true, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
        }
    }
}
