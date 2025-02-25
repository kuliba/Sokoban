//
//  RootViewModelFactory+getSavingsAccountInfo.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import Foundation
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func getSavingsAccountInfo(
        product: ProductData,
        completion: @escaping (GetSavingsAccountInfoServices.SAInfo?) -> Void
    ) {
        guard let account = product.asAccount,
              account.isSavingAccount == true,
              let accountNumber = account.accountNumber
        else { return completion(nil) }
        
        let service = onBackground(
            makeRequest: RequestFactory.createGetSavingsAccountInfoRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetSavingsAccountInfoResponse
        )
        let accountID = (accountNumber as NSString).integerValue
        
        service(.init(accountID: accountID)) {
            
            completion(try? $0.get())
            _ = service
        }
    }
}
