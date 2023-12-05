//
//  Info.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

extension GetSberQRDataResponse.Parameter {

    struct Info: Equatable {
        
        let id: String
        let value: String
        let title: String
        let icon: Icon
        
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
