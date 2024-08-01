//
//  AnySchedulerOfDispatchQueue.swift
//  
//
//  Created by Igor Malyarov on 15.01.2024.
//

import CombineSchedulers
import Foundation

public typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>

public extension AnySchedulerOfDispatchQueue {
    
    static func makeMain() -> AnySchedulerOfDispatchQueue { .main }
}
