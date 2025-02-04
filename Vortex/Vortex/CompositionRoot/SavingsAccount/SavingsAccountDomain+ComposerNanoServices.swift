//
//  SavingsAccountDomain+ComposerNanoServices.swift
//
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import Foundation
import SavingsServices

extension SavingsAccountDomain {
    
    struct ComposerLandingNanoService {
        
        let loadLanding: LoadLanding
    }
    
    struct ComposerOpenNanoServices {
        
        let loadLanding: LoadOpenSavingsAccountLanding
    }
}

extension SavingsAccountDomain {
    
    typealias LandingType = String
    typealias LoadLandingCompletion = (Result<Landing, ContentError>) -> Void
    typealias LoadLanding = (LandingType, @escaping LoadLandingCompletion) -> Void
    
    typealias LoadOpenSavingsAccountLandingCompletion = (Result<OpenAccountLanding, ContentError>) -> Void
    typealias LoadOpenSavingsAccountLanding = (@escaping LoadOpenSavingsAccountLandingCompletion) -> Void
}
