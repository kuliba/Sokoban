//
//  ListDropDownTexts.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct ListDropDownTexts: Decodable, Equatable {
        
        let title: String?
        let list: [Item]
        
        struct Item: Decodable, Equatable {
            
            let title, description: String
        }
    }
}

