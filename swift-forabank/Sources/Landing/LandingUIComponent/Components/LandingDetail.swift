//
//  LandingDetail.swift
//  
//
//  Created by Andryusina Nataly on 15.09.2023.
//

import Tagged

extension UILanding {
    
    public struct Detail: Hashable {
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(groupID)
        }
        
        public let groupID: GroupID
        public let dataGroup: [DataGroup]
        
        public init(
            groupID: GroupID,
            dataGroup: [DataGroup]
        ) {
            self.groupID = groupID
            self.dataGroup = dataGroup
        }
        
        public typealias GroupID = Tagged<_GroupID, String>
        public typealias ViewID = Tagged<_ViewID, String>
        
        public enum _GroupID {}
        public enum _ViewID {}
        
        
        public struct DataGroup: Equatable {
            
            public let viewID: ViewID
            public let dataView: [UILanding.Component]
            
            public init(
                viewID: ViewID,
                dataView: [UILanding.Component]
            ) {
                self.viewID = viewID
                self.dataView = dataView
            }
        }
    }
}
