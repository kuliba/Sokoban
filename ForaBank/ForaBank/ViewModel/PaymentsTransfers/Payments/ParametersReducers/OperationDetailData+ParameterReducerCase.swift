//
//  OperationDetailData+ParameterReducerCase.swift
//  ForaBank
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
                    .successAdditionalButtons,
                    .successActionButton]
            
        default:
            return nil
        }
    }
}
