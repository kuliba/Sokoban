//
//  Info.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

public extension GetSberQRDataResponse.Parameter {
    
    struct Info: Equatable {
        
        let id: ID
        let value: String
        let title: String
        let icon: Icon
        
        public init(
            id: ID,
            value: String,
            title: String,
            icon: Icon
        ) {
            self.id = id
            self.value = value
            self.title = title
            self.icon = icon
        }
    }
}

public extension GetSberQRDataResponse.Parameter.Info {
    
    enum ID: String, Equatable {
        
        case amount, brandName, recipientBank
    }
    
    struct Icon: Equatable {
        
        let type: IconType
        let value: String
        
        public init(
            type: IconType,
            value: String
        ) {
            self.type = type
            self.value = value
        }
        
        public enum IconType: Equatable {
            
            case local
            case remote
        }
    }
}
