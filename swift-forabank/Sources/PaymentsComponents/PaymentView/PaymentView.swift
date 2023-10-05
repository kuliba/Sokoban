//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 03.10.2023.
//

import Foundation
import SwiftUI
import Combine

extension PaymentView {
    
    class ViewModel {
        
        @Published var state: State
        @Published var parameters: [Operation.Parameter]
        
        init(
            state: State,
            parameters: [Operation.Parameter]
        ) {
            self.state = state
            self.parameters = parameters
        }
        
        enum State {
            case update
            case `continue`
        }
    }
}

struct PaymentView: View {
    
    let viewModel: PaymentView.ViewModel
    let button: ButtonType
    
    var body: some View {
        
        VStack {
            
            ForEach(viewModel.parameters.indices, id: \.self) { index in
                
                parameterView(with: viewModel.parameters[index])
            }
            
            buttonView(with: button)
        }
    }
    
    func parameterView(with parameter: Operation.Parameter) -> some View {
        
        switch parameter {
        case let .hint(parameterHint):
            return EmptyView()
        case let .input(parameterInput):
            return EmptyView()
        case let .selector(parameterSelector):
            return EmptyView()
        case let .sticker(parameterSticker):
            return EmptyView()
        case let .product(parameterProduct):
            return EmptyView()
        }
    }
    
    func buttonView(with buttonType: ButtonType) -> some View {
        
        AnyView(
            button(buttonType: buttonType)
        )
    }
    
    func button(buttonType: ButtonType) -> any View {
        
        switch buttonType {
        case let .continue(style):
            
            switch style {
            case .active:
                return activeButton()
                
            case .inactive:
                return inactiveButton()
            }
        
        case .makePayment:
            return EmptyView()

        }
    }
    
    func inactiveButton() -> some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Продолжить")
                .font(.body)
                .foregroundColor(.gray)
        }
    }
    
    func activeButton() -> some View {
        
        AnyView(
            
            Button {
                
                //viewModel.action()
                
            } label: {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.red)
                    
                    Text("Продолжить")
                        .font(.body)
                        .foregroundColor(.white)
                }
            }
        )
    }
}

extension PaymentView {
    
    enum ButtonType {
        
        case `continue`(Style)
        case makePayment
    }
    
    enum Style {
        
        case inactive
        case active
    }
}
