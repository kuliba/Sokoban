//
//  StatusReporting.swift
//  
//
//  Created by Igor Malyarov on 01.02.2024.
//

public protocol StatusReporting<Status> {
    
    associatedtype Status
    
    var status: Status { get }
}
