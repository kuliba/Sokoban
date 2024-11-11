//
//  Schedulers+ext.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

extension PayHubUI.Schedulers {
    
    static let immediate: Self = .init(
        main: .immediate,
        interactive: .immediate,
        userInitiated: .immediate,
        background: .immediate
    )
    
    static func test() -> (Self, TestSchedulers) {
        
        let testSchedulers = TestSchedulers()
        
        let schedulers = Self(
            main: testSchedulers.main.eraseToAnyScheduler(),
            interactive: testSchedulers.interactive.eraseToAnyScheduler(),
            userInitiated: testSchedulers.userInitiated.eraseToAnyScheduler(),
            background: testSchedulers.background.eraseToAnyScheduler()
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
