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
import Combine

extension CreateDraftCollateralLoanApplicationDomain {
    
    public struct Confirmation {
        
        public let otpViewModel: TimedOTPInputViewModel
        
        public init(
            otpViewModel: TimedOTPInputViewModel
        ) {
            self.otpViewModel = otpViewModel
        }
    }
    
    public struct State<Confirmation> {
        
        public let data: Data

        public var amount: TextInputState
        public var applicationID: UInt?
        public var city: OptionalSelectorState<CityItem>
        public var isLoading: Bool
        public var needToDissmiss: Bool
        public var period: OptionalSelectorState<PeriodItem>
        public var saveConsentsResult: SaveConsentsResult?
        public var stage: Stage
        public var otp: String
        public var verificationCode: String
        public var checkedConsents: [String]
        public var isButtonDisabled: Bool
        public var confirmation: Confirmation?
        public var otpValidated: Bool
        
        public init(
            data: Data,
            stage: Stage = .correctParameters,
            isLoading: Bool = false,
            applicationID: UInt? = nil,
            needToDissmiss: Bool = false,
            otp: String = "",
            verificationCode: String = "",
            checkedConsents: [String] = [],
            isButtonDisabled: Bool = false,
            confirmation: Confirmation? = nil,
            otpValidated: Bool = false
        ) {
            self.data = data
            self.stage = stage
            self.isLoading = isLoading
            self.applicationID = applicationID
            self.needToDissmiss = needToDissmiss
            self.period = data.makePeriodSelectorState()
            self.city = data.makeCitySelectorState()
            self.amount = .init(textField: .noFocus(data.formattedAmount))
            self.otp = otp
            self.verificationCode = verificationCode
            self.checkedConsents = checkedConsents
            self.isButtonDisabled = isButtonDisabled
            self.confirmation = confirmation
            self.otpValidated = otpValidated
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
        let isSecondStageValid = checkedConsents.count == data.consents.count
            && confirmation != nil
            && otpValidated
        
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
    
    func saveConsentspayload(
        applicationID: UInt,
        verificationCode: String
    ) -> CollateralLandingApplicationSaveConsentsPayload {
        
        .init(
            applicationID: applicationID,
            verificationCode: otp
        )
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Confirmation {
    
    static let preview = CreateDraftCollateralLoanApplicationDomain.Confirmation(otpViewModel: .preview)
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
