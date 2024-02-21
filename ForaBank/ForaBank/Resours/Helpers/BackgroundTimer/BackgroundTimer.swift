//
//  BackgroundTimer.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.10.2021.
//

import Foundation

public class TimerRepeat {

    let timeInterval: TimeInterval
    
    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    let queue = DispatchQueue(label: "serial.queue.1", qos: .default)
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    public var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    public func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    public func suspended() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
}

