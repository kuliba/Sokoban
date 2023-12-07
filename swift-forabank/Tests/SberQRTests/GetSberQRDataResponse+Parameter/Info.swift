//
//  Info.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

extension GetSberQRDataResponse.Parameter {

    struct Info: Equatable {
        
        let id: ID
        let value: String
        let title: String
        let icon: Icon
        
        enum ID: String, Equatable {
            
            case amount, brandName, recipientBank
        }
        
        struct Icon: Equatable {
            
            let type: IconType
            let value: String
            
            enum IconType: Equatable {
                
                case local
                case remote
            }
        }
    }
}
