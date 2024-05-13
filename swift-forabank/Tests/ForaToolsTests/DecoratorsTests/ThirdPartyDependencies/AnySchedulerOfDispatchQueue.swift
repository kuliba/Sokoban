//
//  AnySchedulerOfDispatchQueue.swift
//  
//
//  Created by Igor Malyarov on 25.04.2023.
//

import CombineSchedulers
import Foundation

typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>
typealias TestSchedulerOfDispatchQueue = TestSchedulerOf<DispatchQueue>

extension AnySchedulerOfDispatchQueue {
    
    static func makeMain() -> AnySchedulerOfDispatchQueue { .main }
}
