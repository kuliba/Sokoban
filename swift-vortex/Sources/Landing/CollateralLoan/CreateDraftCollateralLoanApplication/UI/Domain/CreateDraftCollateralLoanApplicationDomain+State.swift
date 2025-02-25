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
import Combine

extension CreateDraftCollateralLoanApplicationDomain {
    
    public struct State<Confirmation, InformerPayload> where Confirmation: TimedOTPInputViewModel {
        
        public let application: Application

        public var applicationID: UInt?
        public var isLoading: Bool
        public var otp: String
        public var saveConsentsResult: CollateralLandingApplicationSaveConsentsResult?
        public var failure: BackendFailure<InformerPayload>?

        // MARK: UI parameters
        public var amount: TextInputState
        public var city: OptionalSelectorState<CityItem>
        public var period: OptionalSelectorState<PeriodItem>
        public var checkedConsents: [String]
        public var confirmation: Confirmation?
        public var stage: Stage
        
        // MARK: Helpers
        private let formatCurrency: FormatCurrency
        
        public init(
            application: Application,
            isLoading: Bool = false,
            applicationID: UInt? = nil,
            otp: String = "",
            isButtonDisabled: Bool = false,
            confirmation: Confirmation? = nil,
            otpValidated: Bool = false,
            stage: Stage = .correctParameters,
            formatCurrency: @escaping FormatCurrency
        ) {
            self.application = application
            self.isLoading = isLoading
            self.applicationID = applicationID
            self.period = application.makePeriodSelectorState()
            self.city = application.makeCitySelectorState()
            self.amount = .init(textField: .noFocus(formatCurrency(application.amount) ?? ""))
            self.otp = otp
            self.confirmation = confirmation
            self.stage = stage
            self.formatCurrency = formatCurrency
            self.checkedConsents = application.consents.map(\.name)
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
        
        selectedAmount >= application.minAmount && selectedAmount <= application.maxAmount
    }
    
    public var isButtonEnabled: Bool {
        
        let isFirstStageValid = isAmountVaild && !selectedCity.isEmpty
        let isSecondStageValid = checkedConsents.count == application.consents.count
            && confirmation != nil
            && otp.count == 6
        
        switch stage {
        case .correctParameters:
            return isFirstStageValid

        case .confirm:
            return isFirstStageValid && isSecondStageValid
        }
    }
    
    public var selectedCity: String {
        
        city.selected?.title ?? ""
    }
    
    public var formattedAmount: String? {
        
        formatCurrency(application.amount)
    }

    public var hintText: String {
        
        guard
            let minAmount = formatCurrency(application.minAmount),
            let maxAmount = formatCurrency(application.maxAmount)
        else { return "" }
        
        return "Мин. - \(minAmount), Макс. - \(maxAmount)"
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
    
    func saveConsentsPayload(
        applicationID: UInt,
        verificationCode: String
    ) -> CollateralLandingApplicationSaveConsentsPayload {
        
        .init(
            applicationID: applicationID,
            verificationCode: otp
        )
    }
}

public extension CreateDraftCollateralLoanApplication {
    
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

    func makeCitySelectorState(selectedCity: String = "") -> OptionalSelectorState<CityItem> {
        
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
    
    typealias Application = CreateDraftCollateralLoanApplication
    typealias FormatCurrency = (UInt) -> String?
}
