//
//  LandingHeader.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct Header: Equatable {
        
        let type: LandingComponentsType
        let data: PageTitle
        
        public init(
            type: LandingComponentsType,
            data: PageTitle
        ) {
            
            self.type = type
            self.data = data
        }
    }
}
