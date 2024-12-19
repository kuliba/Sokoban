//
//  DetailDestination.swift
//  
//
//  Created by Igor Malyarov on 05.09.2023.
//

import Tagged

public struct DetailDestination: Hashable {
    
    public let groupID: GroupID
    public let viewID: ViewID
    
    public init(
        groupID: GroupID,
        viewID: ViewID
    ) {
        self.groupID = groupID
        self.viewID = viewID
    }
    
    public typealias GroupID = Tagged<_GroupID, String>
    public typealias ViewID = Tagged<_ViewID, String>
    
    public enum _GroupID {}
    public enum _ViewID {}
}
