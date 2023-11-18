//
//  OperationView.swift
//
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct ConfigurationOperationView {

    let tipViewConfig: TipViewConfiguration
    let stickerViewConfig: StickerViewConfiguration
    let selectViewConfig: SelectViewConfiguration
    let productViewConfig: ProductView.Appearance
    let inputViewConfig: InputConfiguration
    let amountViewConfig: AmountViewConfiguration
    
    public init(
        tipViewConfig: TipViewConfiguration,
        stickerViewConfig: StickerViewConfiguration,
        selectViewConfig: SelectViewConfiguration,
        productViewConfig: ProductView.Appearance,
        inputViewConfig: InputConfiguration,
        amountViewConfig: AmountViewConfiguration
    ) {
        self.tipViewConfig = tipViewConfig
        self.stickerViewConfig = stickerViewConfig
        self.selectViewConfig = selectViewConfig
        self.productViewConfig = productViewConfig
        self.inputViewConfig = inputViewConfig
        self.amountViewConfig = amountViewConfig
    }
}

public struct OperationView: View {
    
    @ObservedObject var model: OperationStateViewModel
    let configuration: ConfigurationOperationView
    
    public init(
        model: OperationStateViewModel,
        configuration: ConfigurationOperationView
    ) {
        self.model = model
        self.configuration = configuration
    }
    
    public var body: some View {

        switch model.state {
        case .operation:
            OperationProcessView(
                model: model,
                configuration: configuration
            )
            .padding(.bottom, 20)
        
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
    let configuration: ConfigurationOperationView
    
    var body: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    ForEach(model.scrollParameters) { parameter in
                        
                        parameterView(
                            parameter: parameter,
                            configuration: configuration
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            continueButton(configuration: configuration)
        }
    }
    
    @ViewBuilder
    private func continueButton(
        configuration: ConfigurationOperationView
    ) -> some View {
        
        if let amount = model.amountParameter {
            
            parameterView(
                parameter: amount,
                configuration: configuration
            )
            
        } else {
            
            Button {
                model.event(.continueButtonTapped(.continue))
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
        parameter: Operation.Parameter,
        configuration: ConfigurationOperationView
    ) -> some View {
        
        let mapper = ModelToViewModelMapper(model)
        let viewModel = mapper.map(parameter)
        
        ParameterView(
            viewModel: viewModel,
            configuration: configuration,
            event: { inputEvent in
                
                model.event(.input(inputEvent))
            }
        )
    }
}

extension Operation.Parameter: Identifiable {
    
    public var id: ParameterType {
        
        switch self {
        case .tip: return .tip
        case .sticker: return .sticker
        case let .select(select):
            
            switch select.id {
            case .citySelector:
                return .city
                
            case .transferTypeSticker:
                return .transferType
        
            default:
                return .branches
            }
        case .productSelector: return .productSelector
        case .amount: return .amount
        case .input: return .input
        }
    }
    
    public enum ParameterType: String {
        
        case tip
        case sticker
        case city
        case transferType
        case branches
        case productSelector
        case amount
        case input
    }
}

extension ModelToViewModelMapper {
    
    public init(_ model: OperationStateViewModel) {
        
        self.action = model.event(_:)
    }
}

struct OperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        EmptyView()
    }
}
