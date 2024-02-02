//
//  AnySchedulerOfDispatchQueue.swift
//
//

import CombineSchedulers
import Foundation

public typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>

public extension AnySchedulerOfDispatchQueue {
    
    static func makeMain() -> AnySchedulerOfDispatchQueue { .main }
}
