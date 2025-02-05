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
    
    public final class Reducer {
        
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
        
        public func reduce(_ state: State<TimedOTPInputViewModel>, _ event: Event)
            -> (State<TimedOTPInputViewModel>, Effect?) {
            
            var state = state
            var effect: Effect?
            
            switch event {
            case let .amount(amountEvent):
                state.amount = amountReduce(state.amount, amountEvent)
                if state.isAmountVaild {
                    
                    state.amount.message = .hint(state.data.hintText)
                } else {

                    state.amount.message = .warning("Некорректная сумма")
                }
                state.isButtonDisabled = !state.checkButtonStatus
                
            case let .period(periodEvent):
                state.period = periodSelectReduce(state.period, periodEvent)
                
            case let .city(cityEvent):
                state.city = citySelectReduce(state.city, cityEvent)
                
            case .tappedContinue:
                state.isLoading = true
                effect = .createDraftApplication(state.createDraftApplicationPayload)
                
            case let .applicationCreated(result):
                state.applicationId = try? result.get().applicationId
                state.stage = .confirm
                state.isButtonDisabled = !state.checkButtonStatus
                state.isLoading = false
                
            case .tappedSubmit:
                state.isLoading = true
                effect = .saveConsents(state.saveConsentspayload)
                
            case .tappedBack:
                if state.stage == .confirm {
                    
                    state.stage = .correctParameters
                }
                
            case let .showSaveConsentsResult(result):
                state.isLoading = false
                state.saveConsentsResult = result     
                
            case let .otp(otp):
                state.otp = otp
                
            case .getVerificationCode:
                effect = .getVerificationCode
                
            case .gettedVerificationCode:
                break
                
            case let .checkConsent(consentName):
                if state.checkedConsents.contains(consentName) {
                    state.checkedConsents.removeAll { $0 == consentName }
                } else {
                    state.checkedConsents.append(consentName)
                }
                state.isButtonDisabled = !state.checkButtonStatus
                
            case .otpValidated:
                state.isOTPValidated = true
            }
            
            return (state, effect)
        }
    }
    
    public typealias TextFieldReduce = (TextInputState, TextInputEvent) -> TextInputState
    public typealias Validate = (TextFieldState) -> TextInputState.Message?
    public typealias AmountReduce = TextFieldReduce
    public typealias CitySelectState = OptionalSelectorState<CityItem>
    public typealias CitySelectEvent = OptionalSelectorEvent<CityItem>
    public typealias PeriodSelectState = OptionalSelectorState<PeriodItem>
    public typealias PeriodSelectEvent = OptionalSelectorEvent<PeriodItem>
    public typealias CitySelectReduce = (CitySelectState, CitySelectEvent) -> CitySelectState
    public typealias PeriodSelectReduce = (PeriodSelectState, PeriodSelectEvent) -> PeriodSelectState
}

public extension CreateDraftCollateralLoanApplicationDomain.Reducer {
    
    convenience init(
        data: CreateDraftCollateralLoanApplicationUIData,
        placeholderText: String = "Введите значение",
        warningText: String = "Некорректная сумма"
    ) {
        let decimalFormatter = DecimalFormatter(currencySymbol: "₽")
        
        let textFieldReducer = ChangingReducer.decimal(formatter: decimalFormatter)
        
        let textInputValidator = TextInputValidator(
            hintText: data.hintText,
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
            
            return amount >= data.minAmount && amount <= data.maxAmount
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
