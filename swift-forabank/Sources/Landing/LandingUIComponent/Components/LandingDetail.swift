//
//  LandingDetail.swift
//  
//
//  Created by Andryusina Nataly on 15.09.2023.
//

import Tagged

extension UILanding {
    
    public struct Detail: Equatable {
        
        var id: String { groupID.rawValue }
        let groupID: GroupID
        let dataGroup: [DataGroup]
        
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
            
            let viewID: ViewID
            let dataView: [UILanding.Component]
            
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
