//
//  OperationDetailData+ParameterReducerCase.swift
//  Vortex
//
//  Created by Max Gribov on 23.06.2023.
//

import Foundation

extension OperationDetailData
    .TransferEnum: PaymentsParametersReducerCase {
    
    var parametersOrder: [Payments.Parameter.Identifier]? {
        
        //TODO: check if this order correct
        switch self {
        case .direct:
            return [.successStatus,
                    .successTitle,
                    .successAmount,
                    .successLogo,
                    .successOptionButtons,
                    .successAdditionalButtons,
                    .successActionButton]
            
        case .changeOutgoing, .returnOutgoing:
            return [.successStatus,
                    .successTitle,
                    .successAmount,
                    .successLogo,
                    .successActionButton]
            
        case .contactAddressing, .contactAddressless, .contactAddressingCash:
            return [.successStatus,
                    .successTitle,
                    .successAmount,
                    .successLogo,
                    .successTransferNumber,
                    .successOptions,
                    .successOptionButtons,
                    .successAdditionalButtons,
                    .successActionButton]
            
        default:
            return nil
        }
    }
}
