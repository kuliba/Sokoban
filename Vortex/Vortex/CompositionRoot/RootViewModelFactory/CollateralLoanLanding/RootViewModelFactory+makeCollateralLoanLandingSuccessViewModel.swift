//
//  RootViewModelFactory+makeCollateralLoanLandingSuccessViewModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 20.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

extension RootViewModelFactory {
    
    func makeCollateralLoanLandingSuccessViewModel() -> MakeCollateralLoanLandingSuccessViewModel {
        
        return { .init(paymentSuccess: $0.success, self.model) }
    }
    
    typealias MakeCollateralLoanLandingSuccessViewModel
            = (CollateralLoanLandingResponse) -> PaymentsSuccessViewModel
}

// MARK: - Adapter

extension CollateralLoanLandingResponse {
    
    var success: Payments.Success {
        
        var parameters = parameters.map(\.representable)
        parameters.append(Payments.ParameterSuccessMode(mode: .collateralLoanLanding))

        return .init(
            operation: nil,
            parameters: parameters
        )
    }
}

private typealias Parameter = CollateralLoanLandingResponse.Parameter

private extension CollateralLoanLandingResponse.Parameter {
    
    var representable: PaymentsParameterRepresentable {
        
        switch self {
            
        case let .successText(successText):
            return successText.parameterSuccessText
        }
    }
}

private extension Parameter.SuccessText {
    
    var parameterSuccessText: Payments.ParameterSuccessText {
        
        .init(value: value, style: style.textStyle)
    }
}

private extension CollateralLoanLandingParameters.Style {
    
    var textStyle: Payments.ParameterSuccessText.Style {
        
        switch self {
        case .title: return .title
        case .message: return .title
        }
    }
}
