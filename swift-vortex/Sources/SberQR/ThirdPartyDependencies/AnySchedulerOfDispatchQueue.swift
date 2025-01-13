//
//  AnySchedulerOfDispatchQueue.swift
//  
//
//  Created by Igor Malyarov on 25.04.2023.
//

import CombineSchedulers
import Foundation

public typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>

public extension AnySchedulerOfDispatchQueue {
    
    static func makeMain() -> AnySchedulerOfDispatchQueue { .main }
}
