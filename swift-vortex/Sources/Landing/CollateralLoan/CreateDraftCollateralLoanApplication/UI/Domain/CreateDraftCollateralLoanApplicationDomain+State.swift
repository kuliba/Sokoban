//
//  CreateDraftCollateralLoanApplicationDomain+State.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import Foundation
import InputComponent
import OptionalSelectorComponent
import OTPInputComponent
import TextFieldDomain
import FlowCore

extension CreateDraftCollateralLoanApplicationDomain {
    
    public struct State {
        
        public let data: Data

        public var amount: TextInputState
        public var applicationId: UInt?
        public var city: OptionalSelectorState<CityItem>
        public var isLoading: Bool
        public var needToDissmiss: Bool
        public var period: OptionalSelectorState<PeriodItem>
        public var saveConsentsResult: SaveConsentsResult?
        public var stage: Stage
        public var otp: String
        public var checkedConsents: [String]
        public var isButtonDisabled: Bool
        public var isOTPValidated: Bool
        
        var otpViewModel: TimedOTPInputViewModel?
        var otpViewModelNode: Node<TimedOTPInputViewModel>?

        public init(
            data: Data,
            stage: Stage = .correctParameters,
            isLoading: Bool = false,
            applicationId: UInt? = nil,
            needToDissmiss: Bool = false,
            otp: String = "",
            checkedConsents: [String] = [],
            isButtonDisabled: Bool = false,
            isOTPValidated: Bool = false
        ) {
            self.data = data
            self.stage = stage
            self.isLoading = isLoading
            self.applicationId = applicationId
            self.needToDissmiss = needToDissmiss
            self.period = data.makePeriodSelectorState()
            self.city = data.makeCitySelectorState()
            self.amount = .init(textField: .noFocus(data.formattedAmount))
            self.otp = otp
            self.checkedConsents = checkedConsents
            self.isButtonDisabled = isButtonDisabled
            self.isOTPValidated = isOTPValidated
        }
        
        public enum Stage {
            
            case correctParameters
            case confirm
        }
        
        public enum FieldID: String {
            
            case amount
            case city
            case header
            case percent
            case period
            
            var id: String { rawValue }
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.State {
    
    public var selectedAmount: UInt {
        
        guard
            let amountText = amount.textField.text,
            let amount = UInt(amountText.filter { $0.isNumber })
        else { return 0 }
        
        return amount
    }
    
    public var isAmountVaild: Bool {
        
        selectedAmount >= data.minAmount && selectedAmount <= data.maxAmount
    }
    
    public var checkButtonStatus: Bool {
        
        let isFirstStageValid = isAmountVaild
        let isSecondStageValid = checkedConsents.count == data.consents.count && isOTPValidated
        
        switch stage {
        case .correctParameters:
            return isFirstStageValid

        case .confirm:
            return isFirstStageValid && isSecondStageValid
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain {
    
    public struct PeriodItem: Equatable {
        
        let months: UInt
        let title: String
    }
    
    public struct CityItem: Equatable {
        
        let title: String
    }
}

extension CreateDraftCollateralLoanApplicationDomain.PeriodItem: Identifiable {
    
    public var id: String {
        
        title
    }
}

extension CreateDraftCollateralLoanApplicationDomain.CityItem: Identifiable {
    
    public var id: String {
        
        title
    }
}

extension CreateDraftCollateralLoanApplicationDomain.State {
    
    var createDraftApplicationPayload: CollateralLandingApplicationCreateDraftPayload {
        
        // TODO: Need to realize. Stub!
        .init(
            name: "Кредит под залог транспорта",
            amount: 1000000,
            termMonth: 12,
            collateralType: "CAR",
            interestRate: 18.5,
            collateralInfo: "Лада веста 2012 года выпуска",
            cityName: "Москва",
            payrollClient: true
        )
    }
    
    var saveConsentspayload: CollateralLandingApplicationSaveConsentsPayload {
        
        // TODO: Need to realize. Stub!
        .init(
            applicationId: 123,
            verificationCode: "123"
        )
    }

    func makeTimedOTPInputViewModel(
        timerDuration: Int,
        otpLength: Int,
        event: @escaping (Event) -> Void
    ) -> TimedOTPInputViewModel {
        
        if let otpViewModelNode { return otpViewModelNode.model }
        
        let model = TimedOTPInputViewModel(
            otpText: otp,
            timerDuration: timerDuration,
            otpLength: otpLength,
            resend: { event(.getVerificationCode) },
            observe: { event(.otp($0)) }
        )
        
        let cancellable = model.$state
            .sink(receiveValue: {
                if $0.status == .validOTP {
                    event(.otpValidated)
                }
        })
        
        otpViewModelNode = Node(model: model, cancellable: cancellable)
    }

    
    func makeTimedOTPInputViewModelAlt(
        timerDuration: Int,
        otpLength: Int,
        event: @escaping (Event) -> Void
    ) -> TimedOTPInputViewModel {
        
        let countdownReducer = CountdownReducer(duration: timerDuration)
        
        let decorated: OTPInputReducer.CountdownReduce = { otpState, otpEvent in
            
            if case (.completed, .start) = (otpState, otpEvent) {
                event(.getVerificationCode)
            }
            
            return countdownReducer.reduce(otpState, otpEvent)
        }
        
        let otpFieldReducer = OTPFieldReducer(length: otpLength)
        
        let decoratedOTPFieldReduce: OTPInputReducer.OTPFieldReduce = { state, event in
            
            switch event {
            case let .edit(text):
                let text = text.filter(\.isWholeNumber).prefix(otpLength)
                return otpFieldReducer.reduce(state, .edit(.init(text)))
                
            default:
                return otpFieldReducer.reduce(state, event)
            }
        }
        
        let otpInputReducer = OTPComponentInputReducer(
            countdownReduce: decorated,
            otpFieldReduce : decoratedOTPFieldReduce
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: { _ in })
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: { _,_ in })
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        return TimedOTPInputViewModel(
            initialState: .starting(
                phoneNumber: "",
                duration: timerDuration,
                text: otp
            ),
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            timer: RealTimer(),
            observe: { event(.otp($0)) },
            scheduler: .makeMain()
        )
    }
}

extension CreateDraftCollateralLoanApplicationDomain.State {
    
    public static let correntParametersPreview = Self(
        data: .preview,
        stage: .correctParameters
    )

    public static let confirmPreview = Self(
        data: .preview,
        stage: .confirm
    )
}

public extension CreateDraftCollateralLoanApplicationUIData {
    
    func makePeriodSelectorState() -> OptionalSelectorState<PeriodItem> {
        
        let items: [PeriodItem] = periods.map { .init(months: $0.months, title: $0.title) }
        var selectedItem: PeriodItem?
        if let selectedPeriod = periods.first(where: { $0.months == selectedMonths }) {
            
            selectedItem = .init(months: selectedPeriod.months, title: selectedPeriod.title)
        }
        
        return.init(
            items: items,
            filteredItems: items,
            selected: selectedItem
        )
    }

    func makeCitySelectorState() -> OptionalSelectorState<CityItem> {
        
        let items: [CityItem] = cities.map { .init(title: $0) }
        var selectedItem: CityItem?
        if let selectedCity = cities.first(where: { $0 == selectedCity }) {
            
            selectedItem = .init(title: selectedCity)
        }
        
        return .init(
            items: items,
            filteredItems: items,
            selected: selectedItem
        )
    }

    typealias PeriodItem = CreateDraftCollateralLoanApplicationDomain.PeriodItem
    typealias CityItem = CreateDraftCollateralLoanApplicationDomain.CityItem
}

public extension CreateDraftCollateralLoanApplicationDomain.State {
    
    typealias Data = CreateDraftCollateralLoanApplicationUIData
    typealias Period = Data.Period
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias Event = Domain.Event
}
