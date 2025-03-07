//
//  RootViewModelFactory+getPrintFormForSavingsAccount.swift
//  Vortex
//
//  Created by Andryusina Nataly on 06.03.2025.
//

import Foundation
import SavingsAccount
import RemoteServices
import PDFKit

extension RootViewModelFactory {
    
    @inlinable
    func getPrintFormForSavingsAccount(
        accountID: Int,
        completion: @escaping (PDFDocument?) -> Void
    ) {
        let documentService = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetPrintFormForSavingsAccountRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetPrintFormForSavingsAccountResponse
        )
        
        documentService((accountID, nil)) { response in
            
            completion(try? response.get())
            
            _ = documentService
        }
    }
}
