//
//  RootViewModelFactory+getSavingsAccountInfo.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import Foundation
import RemoteServices
import SavingsAccount
import SavingsServices

extension RootViewModelFactory {
    
    @inlinable
    func getSavingsAccountInfo(
        product: ProductData,
        completion: @escaping (SavingsAccountDetailsState?) -> Void
    ) {
        guard let account = product.asAccount,
              account.isSavingAccount == true,
              let accountNumber = account.accountNumber
        else { return completion(nil) }
        
        let service = onBackground(
            makeRequest: RequestFactory.createGetSavingsAccountInfoRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetSavingsAccountInfoResponse
        )
        
        service(.init(accountID: accountNumber)) {
            
            completion(try? $0.map {
                
                return .init(status: .result($0.details))
                
            }.get())
            _ = service
        }
    }
}

// MARK: - Adapters

private extension GetSavingsAccountInfoResponse {
    
    var details: SavingsAccountDetails {
        
        return .init(
            currentInterest: NSDecimalNumber(floatLiteral: interestAmount ?? 0).decimalValue,
            minBalance: NSDecimalNumber(floatLiteral: minRest ?? 0).decimalValue,
            paidInterest: NSDecimalNumber(floatLiteral: interestPaid ?? 0).decimalValue,
            progress: 3,
            currencyCode: "₽"
        )
    }
}
