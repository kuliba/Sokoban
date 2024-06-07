//
//  TypeButtons.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension Landing.DataView.Multi {
    
    struct TypeButtons:  Equatable {
        
        public let md5hash, backgroundColor, text: String
        public let buttonText, buttonStyle: String
        public let textLink: String?
        public let action: Action?
        public let detail: Detail?
        
        public struct Detail:  Equatable {
            public let groupId: GroupId
            public let viewId: ViewId
            
            public init(groupId: GroupId, viewId: ViewId) {
                self.groupId = groupId
                self.viewId = viewId
            }
        }
        
        public struct Action: Equatable {
            
            public let type: String
            public let outputData: OutputData?
            
            public struct OutputData:  Equatable {
                public let tarif: Tarif
                public let type: TypeData
                
                public init(tarif: Tarif, type: TypeData) {
                    self.tarif = tarif
                    self.type = type
                }
            }
        }
        
        public init(md5hash: String, backgroundColor: String, text: String, buttonText: String, buttonStyle: String, textLink: String?, action: Action?, detail: Detail?) {
            self.md5hash = md5hash
            self.backgroundColor = backgroundColor
            self.text = text
            self.buttonText = buttonText
            self.buttonStyle = buttonStyle
            self.textLink = textLink
            self.action = action
            self.detail = detail
        }
        
        public typealias GroupId = Tagged<_GroupId, String>
        public typealias ViewId = Tagged<_ViewId, String>
        public typealias Tarif = Tagged<_Tarif, Int>
        public typealias TypeData = Tagged<_TypeData, Int>

        public enum _GroupId {}
        public enum _ViewId {}
        public enum _Tarif {}
        public enum _TypeData {}
    }
}
