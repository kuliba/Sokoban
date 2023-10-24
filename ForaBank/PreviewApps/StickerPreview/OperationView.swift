//
//  OperationView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

struct OperationView: View {
    
    @ObservedObject var model: OperationStateViewModel
    
    var body: some View {

        switch model.state {
        case .operation:
            OperationProcessView(model: model)
        
        case let .result(result):
            OperationResultView(
                title: result.title,
                description: result.description,
                amount: result.amount
            ) {
                
                Button("details") {
                    
                    print("details")
                }
            }
        }
    }
}

struct OperationResultView<ButtonsView: View>: View {
    
    let title: String
    let description: String
    let amount: String
    let buttonsView: () -> ButtonsView
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Image(systemName: "photo.artframe")
                .frame(width: 88, height: 88)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            
            Text(amount)
                .font(.largeTitle)
                .foregroundColor(.black)
            
            Spacer()
            
            VStack(spacing: 56) {
             
                buttonsView()
                
                Button {
                    
                    print("button end tapped")
                    
                } label: {
                    
                    Text("На главный")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(.trailing, 15)
        .padding(.leading, 16)
        .padding(.vertical, 20)
    }
}

struct OperationProcessView: View {
    
    @ObservedObject var model: OperationStateViewModel
    
    var body: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ForEach(model.scrollParameters, content: parameterView)
                }
            }
            .padding(.horizontal)
            
            continueButton()
        }
    }
    
    @ViewBuilder
    private func continueButton() -> some View {
        
        if let amount = model.amountParameter {
            
            parameterView(parameter: amount)
            
        } else {
            
            Button {
                model.event(.continueButtonTapped)
            } label: {
                
                Text("Продолжить")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func parameterView(
        parameter: Operation.Parameter
    ) -> some View {
        
        let mapper = ModelToViewModelMapper(model)
        let viewModel = mapper.map(parameter)
        
        ParameterView(viewModel: viewModel)
    }
}

extension Operation.Parameter: Identifiable {
    
    var id: ParameterType {
        
        switch self {
        case .tip: return .tip
        case .sticker: return .sticker
        case let .select(select):
            
            switch select.id {
            case "city":
                return .city
            default:
                return .transferType
            }
        case .product: return .product
        case .amount: return .amount
        case .input: return .input
        }
    }
    
    enum ParameterType: String {
        
        case tip
        case sticker
        case city
        case transferType
        case product
        case amount
        case input
    }
}

extension ModelToViewModelMapper {
    
    init(_ model: OperationStateViewModel) {
        
        self.action = model.event(_:)
    }
}

struct OperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperationView(model: .preview)
    }
}
