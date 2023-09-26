//
//  LandingDetail.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct Detail: Equatable {
        
        public let groupId: String
        public let dataGroup: [DataGroup]
        
        public struct DataGroup: Equatable {
            
            public let viewId: String
            public let dataView: [DataView]
            
            public init(
                viewId: String,
                dataView: [DataView]
            ) {
                self.viewId = viewId
                self.dataView = dataView
            }
        }
        
        public init(
            groupId: String,
            dataGroup: [DataGroup]
        ) {
            self.groupId = groupId
            self.dataGroup = dataGroup
        }
    }
}
