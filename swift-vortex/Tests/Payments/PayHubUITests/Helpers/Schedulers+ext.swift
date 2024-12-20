//
//  Schedulers+ext.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

extension PayHub.Schedulers {
    
    static let immediate: Self = .init(
        main: .immediate,
        interactive: .immediate,
        userInitiated: .immediate,
        background: .immediate
    )
    
    static func test(
        main: AnySchedulerOf<DispatchQueue>? = nil,
        interactive: AnySchedulerOf<DispatchQueue>? = nil,
        userInitiated: AnySchedulerOf<DispatchQueue>? = nil,
        background: AnySchedulerOf<DispatchQueue>? = nil
    ) -> (Self, TestSchedulers) {
        
        let testSchedulers = TestSchedulers()
        
        let schedulers = Self(
            main: main ?? testSchedulers.main.eraseToAnyScheduler(),
            interactive: interactive ?? testSchedulers.interactive.eraseToAnyScheduler(),
            userInitiated: userInitiated ?? testSchedulers.userInitiated.eraseToAnyScheduler(),
            background: background ?? testSchedulers.background.eraseToAnyScheduler()
        )
        
        return (schedulers, testSchedulers)
    }
}

struct TestSchedulers {
    
    let main: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    let interactive: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    let userInitiated: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    let background: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
}
