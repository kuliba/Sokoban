//
//  UserAccountViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import Foundation

extension UserAccountViewModel {
    
    static func preview(
        route: Route = .init(),
        flowStub: FlowStub
    ) -> UserAccountViewModel {
        
        let bankDefaultReducer = BankDefaultReducer()
        let contractReducer = ContractReducer(getProducts: { flowStub.getProducts })
        let productsReducer = ProductsReducer(getProducts: { flowStub.getProducts })
        let reducer = FastPaymentsSettingsReducer(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
        
        let effectHandler = FastPaymentsSettingsEffectHandler(
            createContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.createContract)
                }
            },
            getSettings: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.getSettings)
                }
            },
            prepareSetBankDefault: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.prepareSetBankDefault)
                }
            },
            updateContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.updateContract)
                }
            },
            updateProduct: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.updateProduct)
                }
            }
        )
        
        return .init(
            route: route,
            factory: .init(
                makeFastPaymentsSettingsViewModel: {
                    
                    .init(reducer: reducer, effectHandler: effectHandler)
                }
            )
        )
    }
    
    static func preview(
        route: Route = .init(),
        getProducts: @escaping ContractReducer.GetProducts = { .preview },
        createContract: @escaping FastPaymentsSettingsEffectHandler.CreateContract = { _, completion in completion(.success(.active)) },
        getSettings: @escaping FastPaymentsSettingsEffectHandler.GetSettings,
        prepareSetBankDefault: @escaping FastPaymentsSettingsEffectHandler.PrepareSetBankDefault = { $0(.success(())) },
        updateContract: @escaping FastPaymentsSettingsEffectHandler.UpdateContract,
        updateProduct: @escaping FastPaymentsSettingsEffectHandler.UpdateProduct
    ) -> UserAccountViewModel {
        
        let bankDefaultReducer = BankDefaultReducer()
        let contractReducer = ContractReducer(getProducts: getProducts)
        let productsReducer = ProductsReducer(getProducts: getProducts)
        let reducer = FastPaymentsSettingsReducer(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
        
        let effectHandler = FastPaymentsSettingsEffectHandler(
            createContract: createContract,
            getSettings: getSettings,
            prepareSetBankDefault: prepareSetBankDefault,
            updateContract: updateContract,
            updateProduct: updateProduct
        )
        
        return .init(
            route: route,
            factory: .init(
                makeFastPaymentsSettingsViewModel: {
                    
                    .init(reducer: reducer, effectHandler: effectHandler)
                }
            )
        )
    }
}

private extension FastPaymentsSettingsViewModel {
    
    convenience init(
        reducer: FastPaymentsSettingsReducer,
        effectHandler: FastPaymentsSettingsEffectHandler
    ) {
        self.init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

func generateRandom11DigitNumber() -> Int {
    
    let firstDigit = Int.random(in: 1...9)
    let remainingDigits = (1..<11)
        .map { _ in Int.random(in: 0...9) }
        .reduce(0, { $0 * 10 + $1 })
    
    return firstDigit * Int(pow(10.0, 10.0)) + remainingDigits
}
