//
//  SessionAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 20.04.2022.
//

import Foundation
import Combine

class SessionAgent: SessionAgentProtocol {
    
    let action: PassthroughSubject<Action, Never>
    let sessionState: CurrentValueSubject<SessionState, Never>
    
    private var sessionDuration: TimeInterval
    private var lastNetworkActivityTime: TimeInterval
    private var lastUserActivityTime: TimeInterval
    private var sessionExtentThreshold: Double
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
    
    private var timerBindings = Set<AnyCancellable>()
    private var bindings = Set<AnyCancellable>()

    init(sessionDuration: TimeInterval = 300, sessionExtentThreshold: Double = 0.7) {
        
        self.action = .init()
        self.sessionState = .init(.inactive)
        self.sessionDuration = sessionDuration
        self.lastNetworkActivityTime = Date.distantPast.timeIntervalSinceReferenceDate
        self.lastUserActivityTime = Date.distantPast.timeIntervalSinceReferenceDate
        self.sessionExtentThreshold = sessionExtentThreshold
        
        LoggerAgent.shared.log(level: .debug, category: .session, message: "initialized")
        
        bind()
    }
    
    func bind() {

        action
            .sink { [unowned self] action in
            
                switch action {
                case let payload as SessionAgentAction.Session.Start.Response:
                    switch payload.result {
                    case .success(let credentials):
                        LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Start.Response: success")
                        
                        let start = Date.timeIntervalSinceReferenceDate
                        LoggerAgent.shared.log(category: .session, message: "session state: active")
                        sessionState.value = .active(start: start, credentials: credentials)
                        
                        updateLastNetworkActivityTime()
                        
                        LoggerAgent.shared.log(category: .session, message: "sent SessionAgentAction.Session.Extend.Request")
                        self.action.send(SessionAgentAction.Session.Extend.Request())
                        
                    case .failure(let error):
                        LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Start.Response: failure")
                        
                        LoggerAgent.shared.log(category: .session, message: "session state: failed")
                        sessionState.value = .failed(error)
                    }
                    
                case let payload as SessionAgentAction.Session.Extend.Response:
                    switch payload.result {
                    case .success(let duration):
                        LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Extend.Response: success, duration: \(duration)")
                        
                        sessionDuration = duration
                        LoggerAgent.shared.log(level: .debug, category: .session, message: "session duration updated")
                        
                        updateLastNetworkActivityTime()
                        
                    case .failure(let error):
                        LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Extend.Response: failure")
                        
                        LoggerAgent.shared.log(category: .session, message: "session state: failed")
                        sessionState.value = .failed(error)
                    }
                    
                case _ as SessionAgentAction.Event.Network:
                    updateLastNetworkActivityTime()
                    
                case _ as SessionAgentAction.Event.UserInteraction:
                    updateLastUserActivityTime()
                    
                case _ as SessionAgentAction.Session.Terminate:
                    LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Terminate")
                    
                    LoggerAgent.shared.log(category: .session, message: "session state: inactive")
                    sessionState.value = .inactive
                    
                case _ as SessionAgentAction.Timer.Start:
                    LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Timer.Start")
                    
                    updateState(with: Date().timeIntervalSinceReferenceDate)
                    timerStart()
                    
                    
                case _ as SessionAgentAction.Timer.Stop:
                    LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Timer.Stop")
                    
                    timerStop()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func timerStart() {
        
        timer
            .autoconnect()
            .map{ date in date.timeIntervalSinceReferenceDate }
            .sink {[unowned self] time in
                
               updateState(with: time)
                
            }.store(in: &timerBindings)
        
        LoggerAgent.shared.log(category: .session, message: "timer started")
    }
    
    private func timerStop() {
        
        for binding in timerBindings {
            binding.cancel()
        }
        
        timerBindings = Set<AnyCancellable>()
        
        LoggerAgent.shared.log(category: .session, message: "timer stopped")
    }
    
    private func updateState(with time: TimeInterval) {
        
        guard case .active(_, _) = sessionState.value else {
            return
        }
        
        let sessionTimeRemain = Self.sessionTimeRemain(currentTime: time, lastNetworkActivityTime: lastNetworkActivityTime, sessionDuration: sessionDuration)
    
        guard sessionTimeRemain > 0 else {
            
            sessionState.send(.expired)
            return
        }
        
        let isSessionExtendRequired = Self.isSessionExtendRequired(sessionTimeRemain: sessionTimeRemain, sessionDuration: sessionDuration, sessionExtentThreshold: sessionExtentThreshold, lastNetworkActivityTime: lastNetworkActivityTime, lastUserActivityTime: lastUserActivityTime)
        
        if isSessionExtendRequired == true {
            
            action.send(SessionAgentAction.Session.Extend.Request())
        }
    }
    
    static func sessionTimeRemain(currentTime: TimeInterval, lastNetworkActivityTime: TimeInterval, sessionDuration: TimeInterval) -> TimeInterval {
        
        let timeSinceLastNetworkActivity = currentTime - lastNetworkActivityTime
        
        return max(sessionDuration - timeSinceLastNetworkActivity, 0)
    }
    
    static func isSessionExtendRequired(sessionTimeRemain: TimeInterval, sessionDuration: TimeInterval, sessionExtentThreshold: Double, lastNetworkActivityTime: TimeInterval, lastUserActivityTime: TimeInterval) -> Bool {
        
        return Double(sessionTimeRemain / sessionDuration) < (1 - sessionExtentThreshold) && lastUserActivityTime > lastNetworkActivityTime
    }
    
    func updateLastNetworkActivityTime() {
        
        lastNetworkActivityTime = Date().timeIntervalSinceReferenceDate
    }
    
    func updateLastUserActivityTime() {
        
        lastUserActivityTime = Date().timeIntervalSinceReferenceDate
    }
}
