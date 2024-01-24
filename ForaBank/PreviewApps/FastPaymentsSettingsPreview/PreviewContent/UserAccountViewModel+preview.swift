//
//  UserAccountViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent
import Foundation

extension UserAccountViewModel {
    
    #warning("move duration, length and other fields into settings")
    static func preview(
        initialState: OTPInputState? = nil,
        duration: Int = 10,
        length: Int = 6,
        initiate: @escaping CountdownEffectHandler.Initiate = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        
        completion(.success(()))
    }
        },
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP = { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        
        completion(.success(()))
    }
        },
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
        
        let contractEffectHandler = ContractEffectHandler(
            createContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.createContract)
                }
            },
            updateContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.updateContract)
                }
            }
        )
        
        let prepareSetBankDefault: FastPaymentsSettingsEffectHandler.PrepareSetBankDefault = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowStub.prepareSetBankDefault)
            }
        }
        
        let effectHandler = FastPaymentsSettingsEffectHandler(
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getSettings: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.getSettings)
                }
            },
            prepareSetBankDefault: prepareSetBankDefault,
            updateProduct: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.updateProduct)
                }
            }
        )
        
        return .init(
            route: route,
            prepareSetBankDefault: prepareSetBankDefault,
            factory: .init(
                makeFastPaymentsSettingsViewModel: {
                    
                    .init(
                        reducer: reducer,
                        effectHandler: effectHandler,
                        scheduler: $0
                    )
                },
                makeTimedOTPInputViewModel: {
                    
                    .init(
                        viewModel: .default(
                            initialState: initialState,
                            duration: duration,
                            length: length,
                            initiate: initiate,
                            submitOTP: submitOTP,
                            scheduler: $0),
                        scheduler: $0
                    )
                }
            )
        )
    }
    
    static func preview(
        initialState: OTPInputState? = nil,
        duration: Int = 10,
        length: Int = 6,
        initiate: @escaping CountdownEffectHandler.Initiate,
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP,
        route: Route = .init(),
        getProducts: @escaping ContractReducer.GetProducts = { .preview },
        createContract: @escaping ContractEffectHandler.CreateContract = { _, completion in completion(.success(.active)) },
        getSettings: @escaping FastPaymentsSettingsEffectHandler.GetSettings,
        prepareSetBankDefault: @escaping FastPaymentsSettingsEffectHandler.PrepareSetBankDefault = { $0(.success(())) },
        updateContract: @escaping ContractEffectHandler.UpdateContract,
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
        
        let contractEffectHandler = ContractEffectHandler(
            createContract: createContract,
            updateContract: updateContract
        )
        let effectHandler = FastPaymentsSettingsEffectHandler(
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getSettings: getSettings,
            prepareSetBankDefault: prepareSetBankDefault,
            updateProduct: updateProduct
        )
        
        return .init(
            route: route,
            prepareSetBankDefault: prepareSetBankDefault,
            factory: .init(
                makeFastPaymentsSettingsViewModel: {
                    
                    .init(
                        reducer: reducer,
                        effectHandler: effectHandler,
                        scheduler: $0
                    )
                },
                makeTimedOTPInputViewModel: {
                    
                    .init(
                        viewModel: .default(
                            initialState: initialState,
                            duration: duration,
                            length: length,
                            initiate: initiate,
                            submitOTP: submitOTP,
                            scheduler: $0),
                        scheduler: $0
                    )
                }
            )
        )
    }
}

private extension FastPaymentsSettingsViewModel {
    
    convenience init(
        reducer: FastPaymentsSettingsReducer,
        effectHandler: FastPaymentsSettingsEffectHandler,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
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
