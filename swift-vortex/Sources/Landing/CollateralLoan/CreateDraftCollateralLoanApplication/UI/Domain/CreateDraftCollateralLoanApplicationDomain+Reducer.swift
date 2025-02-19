//
//  CreateDraftCollateralLoanApplicationDomain+Reducer.swift
//  
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import Foundation
import InputComponent
import OptionalSelectorComponent
import OTPInputComponent
import TextFieldComponent
import TextFieldDomain

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class Reducer<Confirmation, InformerPayload> where Confirmation: TimedOTPInputViewModel {
        
        private let amountReduce: AmountReduce
        private let citySelectReduce: CitySelectReduce
        private let periodSelectReduce: PeriodSelectReduce
        
        public init(
            amountReduce: @escaping AmountReduce,
            citySelectReduce: @escaping CitySelectReduce,
            periodSelectReduce: @escaping PeriodSelectReduce
        ) {
            self.amountReduce = amountReduce
            self.citySelectReduce = citySelectReduce
            self.periodSelectReduce = periodSelectReduce
        }
        
        public func reduce(
            _ state: State<Confirmation, InformerPayload>,
            _ event: Event<Confirmation, InformerPayload>
        )
        -> (State<Confirmation, InformerPayload>, Effect?) {
            
            var state = state
            var effect: Effect?
            
            switch event {
            case let .amount(amountEvent):
                state.amount = amountReduce(state.amount, amountEvent)
                if state.isAmountVaild {
                    
                    state.amount.message = .hint(state.application.hintText)
                } else {
                    
                    state.amount.message = .warning("Некорректная сумма")
                }
                
            case let .period(periodEvent):
                state.period = periodSelectReduce(state.period, periodEvent)
                
            case let .city(cityEvent):
                state.city = citySelectReduce(state.city, cityEvent)
                
            case .continue:
                state.isLoading = true
                state.stage = .confirm
                effect = .createDraftApplication(state.createDraftApplicationPayload)
                
            case let .applicationCreated(result):
                state.isLoading = false

                guard
                    state.confirmation == nil,
                    state.applicationID == nil
                else { break }
                
                switch result {
                case let .success(success):
                    state.confirmation = success.confirmation
                    state.applicationID = try? success.applicationResult.get().applicationID
                    
                case let .failure(failure):
                    state.failure = failure
                }
                
            case .submit:
                state.isLoading = true
                if let applicationID = state.applicationID {
                    
                    effect = .saveConsents(
                        state.saveConsentsPayload(
                            applicationID: applicationID,
                            verificationCode: state.otp
                        )
                    )
                }
                
            case .back:
                if state.stage == .confirm {
                    
                    state.stage = .correctParameters
                }
                
            case let .showSaveConsentsResult(result):
                switch result {
                case let .success(success):
                    state.saveConsentsResult = success
                    
                case let .failure(failure):
                    state.failure = failure
                }
                
            case .gettedVerificationCode:
                break
                
            case let .checkConsent(consentName):
                if state.checkedConsents.contains(consentName) {
                    state.checkedConsents.removeAll { $0 == consentName }
                } else {
                    state.checkedConsents.append(consentName)
                }
                
            case let .confirmed(confirmation):
                state.confirmation = confirmation
                
            case let .failure(failure):
                state.failure = failure
                
            case let .otpEvent(event):
                switch event {
                    
                case let .otp(otp):
                    state.otp = otp
                    
                case .getVerificationCode:
                    effect = .getVerificationCode
                }
                
            case .dismissFailure:
                state.failure = nil
            }
            
            return (state, effect)
        }
    }
}
  
public extension CreateDraftCollateralLoanApplicationDomain {

    typealias TextFieldReduce = (TextInputState, TextInputEvent) -> TextInputState
    typealias Validate = (TextFieldState) -> TextInputState.Message?
    typealias AmountReduce = TextFieldReduce
    typealias CitySelectState = OptionalSelectorState<CityItem>
    typealias CitySelectEvent = OptionalSelectorEvent<CityItem>
    typealias PeriodSelectState = OptionalSelectorState<PeriodItem>
    typealias PeriodSelectEvent = OptionalSelectorEvent<PeriodItem>
    typealias CitySelectReduce = (CitySelectState, CitySelectEvent) -> CitySelectState
    typealias PeriodSelectReduce = (PeriodSelectState, PeriodSelectEvent) -> PeriodSelectState
}

public extension CreateDraftCollateralLoanApplicationDomain.Reducer {
    
    convenience init(
        application: CreateDraftCollateralLoanApplication,
        placeholderText: String = "Введите значение",
        warningText: String = "Некорректная сумма"
    ) {
        let decimalFormatter = DecimalFormatter(currencySymbol: "₽")
        
        let textFieldReducer = ChangingReducer.decimal(formatter: decimalFormatter)
        
        let textInputValidator = TextInputValidator(
            hintText: application.hintText,
            warningText: warningText,
            validate: { isValid($0) }
        )
        
        let amountReducer = TextInputReducer(
            textFieldReduce: textFieldReducer.reduce(_:_:),
            validate: textInputValidator.validate
        )

        let selectCityReducer = OptionalSelectorReducer<CityItem>(predicate: { $0.title.contains($1) })
        let selectPeriodReducer = OptionalSelectorReducer<PeriodItem>(predicate: { $0.title.contains($1) })
        
        self.init(
            amountReduce: amountReducer.reduce,
            citySelectReduce: selectCityReducer.reduce,
            periodSelectReduce: selectPeriodReducer.reduce
        )
        
        func isValid(_ amount: String) -> Bool {
            
            guard let amount = Int(amount.filter { $0.isNumber }) else { return false }
            
            return amount >= application.minAmount && amount <= application.maxAmount
        }
    }
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias PeriodItem = Domain.PeriodItem
    typealias CityItem = Domain.CityItem
}

private extension OptionalSelectorReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        reduce(state, event).0
    }
}

private extension TextFieldModel.Reducer {
    
    func reduce(
        _ state: TextFieldState,
        _ action: TextFieldAction
    ) -> TextFieldState {
        
        (try? reduce(state, with: action)) ?? state
    }
}

private extension TextInputReducer {
    
    func reduce(
        _ state: TextInputState,
        _ event: TextInputEvent
    ) -> TextInputState {
        
        reduce(state, event).0
    }
}
