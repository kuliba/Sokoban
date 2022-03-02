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
        
        @Published var state: State
        
        init(state: State) {
            self.state = state
        }
        
        enum State {
            
            case inactive(title: String)
            case active(title: String, action: () -> Void )
        }
    }
}

//MARK: - View

struct ButtonSimpleView: View {
    
    @ObservedObject var viewModel: ButtonSimpleView.ViewModel
    
    var body: some View {
        
        switch viewModel.state {
            
        case .inactive(title: let title):
            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(hex: "#D3D3D3"))
                
                Text(title)
                    .font(Font.custom("Inter-Regular", size: 16))
                    .foregroundColor(Color(hex: "#FFFFFF"))
            }
            
        case .active(title: let title, action: let action):
            Button(action: action) {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color(hex: "#FF3636"))
                    
                    Text(title)
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color(hex: "#FFFFFF"))
                }
            }
        }
    }
}

//MARK: - Preview

struct ButtonSimpleView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonSimpleView(viewModel: .init(state: .inactive(title: "Оплатить")))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(state: .inactive(title: "Перевести")))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(state: .inactive(title: "Продолжить")))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(state: .active(title: "Оплатить", action: {})))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(state: .active(title: "На главную", action: {})))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(state: .active(title: "Перевести", action: {})))
                .previewLayout(.fixed(width: 375, height: 70))
            
            ButtonSimpleView(viewModel: .init(state: .active(title: "Продолжить", action: {})))
                .previewLayout(.fixed(width: 375, height: 70))
        }
    }
}
