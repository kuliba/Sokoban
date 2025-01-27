//
//  CreateDraftCollateralLoanApplicationDomain+State.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import InputComponent
import TextFieldDomain

extension CreateDraftCollateralLoanApplicationDomain {
    
    public struct State: Equatable {
        
        public let data: CreateDraftCollateralLoanApplicationUIData

        public var saveConsentsResult: SaveConsentsResult?
        public var stage: Stage
        public var isValid: Bool
        public var isLoading: Bool
        public var applicationId: UInt?
        
        public var textInputState: TextInputState
        
        public init(
            data: CreateDraftCollateralLoanApplicationUIData,
            stage: Stage = .correctParameters,
            isValid: Bool = true,
            isLoading: Bool = false,
            applicationId: UInt? = nil,
            textInputState: TextInputState = .init(textField: .editing(.empty))
        ) {
            self.data = data
            self.stage = stage
            self.isValid = isValid
            self.isLoading = isLoading
            self.applicationId = applicationId
            self.textInputState = textInputState
        }
        
        public enum Stage {
            
            case correctParameters
            case confirm
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.State {
    
    var createDraftApplicationPayload: CollateralLandingApplicationCreateDraftPayload {
        
        // TODO: Need to realize. Mock!
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
        
        // TODO: Need to realize. Mock!
        .init(
            applicationId: 123,
            verificationCode: "123"
        )
    }
}

extension CreateDraftCollateralLoanApplicationDomain.State {
    
    public static let preview = Self(
        data: .preview,
        stage: .correctParameters,
        isValid: true
    )
}
