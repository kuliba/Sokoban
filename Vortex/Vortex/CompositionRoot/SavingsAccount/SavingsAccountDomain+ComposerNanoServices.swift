//
//  SavingsAccountDomain+ComposerNanoServices.swift
//
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import Foundation
import SavingsServices

extension SavingsAccountDomain {
    
    struct ComposerNanoServices {
        
        let loadLanding: LoadLanding
        let orderAccount: OrderAccount
    }
}

extension SavingsAccountDomain {
    
    typealias LandingType = String
    typealias LoadLandingCompletion = (Result<Landing, ContentError>) -> Void
    typealias LoadLanding = (LandingType, @escaping LoadLandingCompletion) -> Void
    
    typealias OrderAccountCompletion = (Result<OpenAccountLanding, ContentError>) -> Void
    typealias OrderAccount = (@escaping OrderAccountCompletion) -> Void
}
