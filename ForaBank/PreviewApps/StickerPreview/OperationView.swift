//
//  OperationView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

struct OperationView: View {
    
    @ObservedObject var model: OperationViewModel
    
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
                
                Text("Continue")
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
    
    var id: String {
        
        switch self {
        case .tip: return "tip"
        case .sticker: return "sticker"
        case let .select(select): return select.id
        case .product: return "product"
        case .amount: return "amount"
        }
    }
}

extension ModelToViewModelMapper {
    
    init(_ model: OperationViewModel) {
        
        self.action = model.event(_:)
    }
}

struct OperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperationView(model: .preview)
    }
}
