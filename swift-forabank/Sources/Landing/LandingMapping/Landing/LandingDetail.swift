//
//  LandingDetail.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct Detail: Equatable {
        
        let detailsGroupId: String
        let dataGroup: [DataGroup]
        
        public struct DataGroup: Equatable {
            
            let detailViewId: String
            let dataView: [DataView]
            
            public init(
                detailViewId: String,
                dataView: [DataView]
            ) {
                self.detailViewId = detailViewId
                self.dataView = dataView
            }
        }
        
        public init(
            detailsGroupId: String,
            dataGroup: [DataGroup]
        ) {
            self.detailsGroupId = detailsGroupId
            self.dataGroup = dataGroup
        }
    }
}
