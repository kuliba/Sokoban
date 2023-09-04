//
//  Header.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct Header: Decodable, Equatable {
        
        let type: LandingComponentsType
        let data: PageTitle
    }
}
