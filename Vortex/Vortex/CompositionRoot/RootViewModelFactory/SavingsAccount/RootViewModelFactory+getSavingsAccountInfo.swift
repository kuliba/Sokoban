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
        
        service(.init(accountNumber: accountNumber)) {
            
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
        
        let calendar = Calendar.current
        let current: Double = Double(calendar.component(.day, from: Date()))
        let next: Double = Double(dateNext?.suffix(2) ?? "1") ?? 1
        
        return .init(
            currentInterest: NSDecimalNumber(floatLiteral: interestAmount ?? 0).decimalValue,
            minBalance: NSDecimalNumber(floatLiteral: minRest ?? 0).decimalValue,
            paidInterest: NSDecimalNumber(floatLiteral: interestPaid ?? 0).decimalValue,
            progress:  current / next,
            dateNext: dateNext,
            currencyCode: "₽"
        )
    }
}
