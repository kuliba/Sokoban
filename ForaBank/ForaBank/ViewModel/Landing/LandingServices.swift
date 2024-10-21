//
//  LandingServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.10.2024.
//

import Foundation
import LandingMapping
import RemoteServices

struct LandingServices {
      
    let loadLandingByType: BannersNanoServices.LoadLandingByType
}

// MARK: - Preview Content

extension LandingServices {
    
    static func empty() -> Self {
        
        .preview(
            landing: .empty()
        )
    }
    
    static func preview(
        landing: Landing
    ) -> Self {
        
        .init(
            loadLandingByType: { _, completion in
                
                completion(.success(landing))
            }
        )
    }
}

extension Landing {
    
    static func empty() -> Self {
        
        .init(header: [], main: [], footer: [], details: [], serial: nil, statusCode: 200, errorMessage: nil)
    }
}
