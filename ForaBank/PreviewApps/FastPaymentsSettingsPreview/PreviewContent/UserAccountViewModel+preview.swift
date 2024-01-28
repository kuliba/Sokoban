//
//  UserAccountViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import Foundation
import OTPInputComponent
import UserAccountNavigationComponent

extension UserAccountViewModel {
    
#warning("move duration, length and other fields into settings")
    static func preview(
        initialState: OTPInputState? = nil,
        duration: Int = 10,
        length: Int = 6,
        state: State = .init(),
        flowStub: FlowStub,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> UserAccountViewModel {
        
        let bankDefaultReducer = BankDefaultReducer()
        let consentListReducer = ConsentListRxReducer()
        let contractReducer = ContractReducer(getProducts: { flowStub.getProducts })
        let productsReducer = ProductsReducer(getProducts: { flowStub.getProducts })
        let reducer = FastPaymentsSettingsReducer(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            consentListReduce: consentListReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
        
        let consentListHandler = ConsentListRxEffectHandler(
            changeConsentList: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.changeConsentList)
                }
            }
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
            handleConsentListEffect: consentListHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getC2BSub: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flowStub.getC2BSub)
                }
            },
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
        
        let initiateOTP: CountdownEffectHandler.InitiateOTP = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowStub.initiateOTP)
            }
        }
        
        let submitOTP: OTPFieldEffectHandler.SubmitOTP = { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowStub.submitOTP)
            }
        }
        
        typealias MakeFastPaymentsSettingsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
        typealias MakeTimedOTPInputViewModel = (AnySchedulerOfDispatchQueue) -> TimedOTPInputViewModel
        
        let makeFastPaymentsSettingsViewModel: MakeFastPaymentsSettingsViewModel = {
            
            .init(
                reducer: reducer,
                effectHandler: effectHandler,
                scheduler: $0
            )
        }
        
        let makeTimedOTPInputViewModel: MakeTimedOTPInputViewModel = {
            
            .init(
                viewModel: .default(
                    initialState: initialState,
                    duration: duration,
                    length: length,
                    initiateOTP: initiateOTP,
                    submitOTP: submitOTP,
                    scheduler: $0),
                scheduler: $0
            )
        }
        
        
        let userAccountNavigationDemoReducer = UserAccountNavigationDemoReducer()
        
        let userAccountNavigationFPSReducer = UserAccountNavigationFPSReducer()
        
        let userAccountNavigationOTPReducer = UserAccountNavigationOTPReducer(
            makeTimedOTPInputViewModel: makeTimedOTPInputViewModel,
            scheduler: scheduler
        )
        
        let userAccountNavigationReducer = UserAccountNavigationReducer(
            demoReduce: userAccountNavigationDemoReducer.reduce(_:_:_:),
            fpsReduce: userAccountNavigationFPSReducer.reduce(_:_:_:),
            otpReduce: userAccountNavigationOTPReducer.reduce(_:_:_:_:),
            scheduler: .makeMain()
        )
        
        let userAccountNavigationOTPEffectHandler = UserAccountNavigationOTPEffectHandler(
            prepareSetBankDefault: prepareSetBankDefault
        )
        
        return .init(
            initialState: state,
            reduce: userAccountNavigationReducer.reduce(_:_:_:_:),
            handleOTPEffect: userAccountNavigationOTPEffectHandler.handleEffect(_:dispatch:),
            makeFastPaymentsSettingsViewModel: makeFastPaymentsSettingsViewModel,
            scheduler: scheduler
        )
    }
    
    static func preview(
        initialState: OTPInputState? = nil,
        reduce: @escaping Reduce,
        duration: Int = 10,
        length: Int = 6,
        initiateOTP: @escaping CountdownEffectHandler.InitiateOTP,
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP,
        state: State = .init(),
        getProducts: @escaping ContractReducer.GetProducts = { .preview },
        changeConsentList: @escaping ConsentListRxEffectHandler.ChangeConsentList,
        createContract: @escaping ContractEffectHandler.CreateContract = { _, completion in completion(.success(.active)) },
        getC2BSub: @escaping FastPaymentsSettingsEffectHandler.GetC2BSub = { $0(.success(.control)) },
        getSettings: @escaping FastPaymentsSettingsEffectHandler.GetSettings,
        prepareSetBankDefault: @escaping FastPaymentsSettingsEffectHandler.PrepareSetBankDefault = { $0(.success(())) },
        updateContract: @escaping ContractEffectHandler.UpdateContract,
        updateProduct: @escaping FastPaymentsSettingsEffectHandler.UpdateProduct,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> UserAccountViewModel {
        
        let bankDefaultReducer = BankDefaultReducer()
        let consentListReducer = ConsentListRxReducer()
        let contractReducer = ContractReducer(getProducts: getProducts)
        let productsReducer = ProductsReducer(getProducts: getProducts)
        let reducer = FastPaymentsSettingsReducer(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            consentListReduce: consentListReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
        
        let consentListHandler = ConsentListRxEffectHandler(
            changeConsentList: changeConsentList
        )
        let contractEffectHandler = ContractEffectHandler(
            createContract: createContract,
            updateContract: updateContract
        )
        let effectHandler = FastPaymentsSettingsEffectHandler(
            handleConsentListEffect: consentListHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getC2BSub: getC2BSub,
            getSettings: getSettings,
            prepareSetBankDefault: prepareSetBankDefault,
            updateProduct: updateProduct
        )
        
        let userAccountOTPEffectHandler = UserAccountNavigationOTPEffectHandler(
            prepareSetBankDefault: prepareSetBankDefault
        )
        
        return .init(
            initialState: state,
            reduce: reduce,
            handleOTPEffect: userAccountOTPEffectHandler.handleEffect(_:dispatch:),
            makeFastPaymentsSettingsViewModel: {
                
                .init(
                    reducer: reducer,
                    effectHandler: effectHandler,
                    scheduler: $0
                )
            },
            scheduler: scheduler
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
