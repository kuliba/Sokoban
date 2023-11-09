//
//  MultiTypeButtons.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct MultiTypeButtons: Decodable, Equatable {
        
        let md5hash, backgroundColor, text: String
        let buttonText, buttonStyle: String
        let textLink: String?
        let action: Action?
        let detail: Detail?
        
        enum CodingKeys: String, CodingKey {
            
            case detail = "details"
            case md5hash, backgroundColor, text
            case buttonText, buttonStyle
            case textLink, action
        }
        
        struct Action: Decodable, Equatable {
            
            let type: String
            let outputData: OutputData?
            
            enum CodingKeys: String, CodingKey {
                case type = "actionType"
                case outputData
            }
            
            struct OutputData: Decodable, Equatable {
                
                let tarif: Int
                let type: Int
                
                enum CodingKeys: String, CodingKey {
                    case type = "cardType"
                    case tarif = "cardTarif"
                }
            }
        }
        
        struct Detail: Decodable, Equatable {
            let groupId: String
            let viewId: String
            
            enum CodingKeys: String, CodingKey {
                case groupId = "detailsGroupId"
                case viewId = "detailViewId"
            }
        }
    }
}
