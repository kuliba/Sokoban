//
//  OperationView.swift
//
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct OperationView<OperationResultView: View>: View {
    
    @StateObject var model: OperationStateViewModel
    let operationResultView: (OperationResult) -> OperationResultView
    let configuration: OperationViewConfiguration
    
    public init(
        model: OperationStateViewModel,
        operationResultView: @escaping (OperationResult) -> OperationResultView,
        configuration: OperationViewConfiguration
    ) {
        self._model = .init(wrappedValue: model)
        self.operationResultView = operationResultView
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
            operationResultView(result)
                .navigationBarBackButtonHidden()
                .navigationTitle("")
        }
    }
}

public struct OperationResultView<ButtonsView: View>: View {
    
    let model: OperationResult
    let buttonsView: (OperationResult.PaymentID) -> ButtonsView
    let configuration: OperationViewConfiguration
    let mainButtonAction: () -> Void
    
    public init(
        model: OperationResult,
        buttonsView: @escaping (OperationResult.PaymentID) -> ButtonsView,
        mainButtonAction: @escaping () -> Void,
        configuration: OperationViewConfiguration
    ) {
        self.model = model
        self.buttonsView = buttonsView
        self.mainButtonAction = mainButtonAction
        self.configuration = configuration
    }
    
    public var body: some View {
        
        VStack(spacing: 20) {
            
            Spacer()
                .frame(minHeight: 20, maxHeight: 112)
            
            VStack(spacing: 24) {
                
                ZStack(alignment: .center) {
                    
                    Circle()
                        .foregroundColor(configuration.resultViewConfiguration.colorSuccess)
                        .frame(width: 88, height: 88, alignment: .center)
                    
                    Image("ic48Check")
                        .foregroundColor(.white)
                        .frame(width: 88, height: 88)
                }
                
                VStack(spacing: 12) {
                    
                    Text(model.title)
                        .font(configuration.resultViewConfiguration.titleFont)
                        .foregroundColor(configuration.resultViewConfiguration.titleColor)
                    
                    Text(model.description)
                        .font(configuration.resultViewConfiguration.descriptionFont)
                        .foregroundColor(configuration.resultViewConfiguration.descriptionColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .frame(minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    
                }
                
                Text("\(model.amount) ₽")
                    .font(configuration.resultViewConfiguration.amountFont)
                    .foregroundColor(configuration.resultViewConfiguration.amountColor)
            }
            
            Spacer()
            
            VStack(spacing: 56) {
             
                buttonsView(model.paymentID)
                
                Button(action: mainButtonAction) {
                    
                    Text("На главный")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(configuration.resultViewConfiguration.mainButtonBackgroundColor)
                        .font(configuration.resultViewConfiguration.mainButtonFont)
                        .foregroundColor(configuration.resultViewConfiguration.mainButtonColor)
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
    let configuration: OperationViewConfiguration
    
    @State private var value: CGFloat = 0

    var body: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    ForEach(model.scrollParameters) { parameter in
                        
                        parameterView(
                            operation: model.operation,
                            parameter: parameter,
                            configuration: configuration
                        )
                    }
                }
            }
            .padding(.horizontal)
            .offset(y: -self.value)
            .onAppear {
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                    
                    if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        
                        let height = value.height - 100
                        self.value = height
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                    
                    self.value = 0
                }
            }
            
            continueButton(
                viewModel: .init(isActive: model.isOperationComplete()),
                model: model,
                configuration: configuration
            )
            .background(Color.clear)
        }
    }
    
    struct ContinueButtonViewModel {
    
        let isActive: Bool
    }
    
    struct ContinueButton: View {
        
        let viewModel: ContinueButtonViewModel
        let model: OperationStateViewModel
        let configuration: OperationViewConfiguration
        
        var body: some View {
            
            Button { model.event(.continueButtonTapped(.continue)) } label: {
                
                Text("Продолжить")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isActive ? Color.red : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .allowsHitTesting(viewModel.isActive ? true : false)
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func continueButton(
        viewModel: ContinueButtonViewModel,
        model: OperationStateViewModel,
        configuration: OperationViewConfiguration
    ) -> some View {
        
        if let amount = model.amountParameter {
            
            parameterView(
                operation: model.operation,
                parameter: amount,
                configuration: configuration
            )
            
        } else if case let .operation(operation) = model.state {
            
            switch operation.state {
            case .process:
                SpinnerRefreshView(icon: .init(configuration.spinnerIcon))
                
            case .userInteraction:
                
                ContinueButton(
                    viewModel: viewModel,
                    model: model,
                    configuration: configuration
                )
                .allowsHitTesting(model.isOperationComplete())
            }
        }
    }
    
    @ViewBuilder
    private func parameterView(
        operation: Operation?,
        parameter: Operation.Parameter,
        configuration: OperationViewConfiguration
    ) -> some View {
        
        let mapper = ModelToViewModelMapper(model)
        let viewModel = mapper.map(operation, parameter)
        
        ParameterView(
            viewModel: viewModel,
            configuration: configuration,
            event: { inputEvent in
                
                model.event(.input(inputEvent))
            }
        )
    }
}

//MARK: Helper

extension OperationStateViewModel {

    public var scrollParameters: [Operation.Parameter] {
        
        operation?.parameters.filter { $0.id != .amount } ?? []
    }
    
    public var amountParameter: Operation.Parameter? {
        
        operation?.parameters.first { $0.id == .amount }
    }
    
    public var product: Operation.Parameter.ProductSelector? {
        
        let product = operation?.parameters.first { $0.id == .productSelector }
        
        switch product {
        case let .productSelector(product):
            return product
            
        default:
            return nil
        }
    }
    
    public var banner: Operation.Parameter.Sticker? {
        
        let product = operation?.parameters.first { $0.id == .sticker }
        
        switch product {
        case let .sticker(sticker):
            return sticker
            
        default:
            return nil
        }
    }
    
    public var transferType: Operation.Parameter.Select? {
        
        let product = operation?.parameters.first { $0.id == .transferType }
        
        switch product {
        case let .select(select):
            return select
            
        default:
            return nil
        }
    }
    
    public func isOperationComplete() -> Bool {
        
        var complete: Bool = true
        
        guard let parameters = operation?.parameters else {
            return false
        }
    
        for parameter in parameters {
            
            if transferType?.id == .transferTypeSticker {
                
                if transferType?.value == "typeDeliveryCourier" {
                    
                    if let maxAmount = self.banner?.options.map({ $0.price }).max(),
                       self.product?.selectedProduct.balance ?? 0 < maxAmount {
                        
                        return false
                    }
                } else if transferType?.value == "typeDeliveryOffice" {
                    
                    if let minAmount = self.banner?.options.map({ $0.price }).min(),
                       self.product?.selectedProduct.balance ?? 0 < minAmount {
                        
                        complete = false
                    }
                }
            }
            
            switch parameter {
            case let .select(select):
                
                if select.value == nil {
                    
                    complete = false
                }
                
            default:
                break
            }
        }
        
        return complete
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

private extension ModelToViewModelMapper {
    
    init(_ model: OperationStateViewModel) {
        
        self.action = model.event(_:)
    }
}

struct OperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        EmptyView()
    }
}
