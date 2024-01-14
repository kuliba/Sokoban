//
//  TestSchedulerOfDispatchQueue.swift
//  
//
//  Created by Igor Malyarov on 16.05.2023.
//

import CombineSchedulers
import Foundation

public typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>
typealias TestSchedulerOfDispatchQueue = TestSchedulerOf<DispatchQueue>

public extension AnySchedulerOfDispatchQueue {
    
    static func makeMain() -> AnySchedulerOfDispatchQueue { .main }
}
