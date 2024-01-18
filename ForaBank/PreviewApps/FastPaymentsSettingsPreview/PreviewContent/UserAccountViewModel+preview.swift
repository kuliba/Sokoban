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
        
        let reducer = FastPaymentsSettingsReducer(
            getProducts: { flowStub.getProducts }
        )
        
        let effectHandler = FastPaymentsSettingsEffectHandler(
            createContract: { _, completion in completion(flowStub.createContract) },
            getSettings: { completion in completion(flowStub.getSettings) },
            prepareSetBankDefault: { completion in completion(flowStub.prepareSetBankDefault) },
            updateContract: { _, completion in completion(flowStub.updateContract) },
            updateProduct: { _, completion in completion(flowStub.updateProduct) }
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
        getProducts: @escaping FastPaymentsSettingsReducer.GetProducts = { .preview },
        createContract: @escaping FastPaymentsSettingsEffectHandler.CreateContract = { _, completion in completion(.success(.active)) },
        getSettings: @escaping FastPaymentsSettingsEffectHandler.GetSettings,
        prepareSetBankDefault: @escaping FastPaymentsSettingsEffectHandler.PrepareSetBankDefault = { $0(.success(())) },
        updateContract: @escaping FastPaymentsSettingsEffectHandler.UpdateContract,
        updateProduct: @escaping FastPaymentsSettingsEffectHandler.UpdateProduct
    ) -> UserAccountViewModel {
        
        let reducer = FastPaymentsSettingsReducer(
            getProducts: getProducts
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
