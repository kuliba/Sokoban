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
    private var sessionExtendThreshold: Double

    private let timer = Timer.publish(every: 1, on: .main, in: .common)
    
    private var timerBindings = Set<AnyCancellable>()
    private var bindings = Set<AnyCancellable>()

    init(sessionDuration: TimeInterval = 300, sessionExtendThreshold: Double = 0.7) {
        
        self.action = .init()
        self.sessionState = .init(.inactive)
        self.sessionDuration = sessionDuration
        self.lastNetworkActivityTime = Date.distantPast.timeIntervalSinceReferenceDate
        self.lastUserActivityTime = Date.distantPast.timeIntervalSinceReferenceDate
        self.sessionExtendThreshold = sessionExtendThreshold
        
        LoggerAgent.shared.log(level: .debug, category: .session, message: "initialized")
        
        bind()
    }

    func bind() {

        action
            .sink { [unowned self] action in
            
                switch action {
                case _ as SessionAgentAction.App.Activated:
                    LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.App.Activated, session: \(sessionState.value)")
                    
                    updateState(with: Date().timeIntervalSinceReferenceDate)
                    timerStart()
                    
                    switch sessionState.value {
                    case .inactive:
                        LoggerAgent.shared.log(category: .session, message: "sent SessionAgentAction.Session.Start.Request")
                        self.action.send(SessionAgentAction.Session.Start.Request())
                        
                    case .active:
                        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                            
                            LoggerAgent.shared.log(category: .session, message: "sent SessionAgentAction.Session.Extend")
                            self.action.send(SessionAgentAction.Session.Extend())
                        }

                    default:
                        break
                    }
                    
                case _ as SessionAgentAction.App.Inactivated:
                    LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.App.Inactivated")
                    
                    timerStop()
                    
                case let payload as SessionAgentAction.Session.Start.Response:
                    switch payload.result {
                    case .success(let credentials):
                        LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Start.Response: success")
                        
                        let start = Date.timeIntervalSinceReferenceDate
                        sessionState.value = .active(start: start, credentials: credentials)
                        
                        LoggerAgent.shared.log(category: .session, message: "sent SessionAgentAction.Session.Timeout.Request")
                        self.action.send(SessionAgentAction.Session.Timeout.Request())
                        
                    case .failure(let error):
                        LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Start.Response: failure")
                        sessionState.value = .failed(error)
                    }
                    
                case let payload as SessionAgentAction.Session.Timeout.Response:
                    switch payload.result {
                    case .success(let duration):
                        LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Timeout.Response: success, duration: \(duration)")
                        
                        sessionDuration = duration
                        LoggerAgent.shared.log(level: .debug, category: .session, message: "session duration updated")
   
                    case .failure(let error):
                        LoggerAgent.shared.log(level: .error, category: .session, message: "received SessionAgentAction.Session.Timeout.Response: failure, error: \(error.localizedDescription)")
                    }
                    
                case _ as SessionAgentAction.Event.Network:
                    updateLastNetworkActivityTime()
                    
                case _ as SessionAgentAction.Event.UserInteraction:
                    updateLastUserActivityTime()
                    
                case _ as SessionAgentAction.Session.Terminate:
                    LoggerAgent.shared.log(category: .session, message: "received SessionAgentAction.Session.Terminate")
                    
                    sessionState.value = .inactive
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        sessionState
            .sink { sessionState in
                
                LoggerAgent.shared.log(category: .session, message: "session: \(sessionState)")
                
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
        
        let isSessionExtendRequired = Self.isSessionExtendRequired(sessionTimeRemain: sessionTimeRemain, sessionDuration: sessionDuration, sessionExtentThreshold: sessionExtendThreshold, lastNetworkActivityTime: lastNetworkActivityTime, lastUserActivityTime: lastUserActivityTime)
        
        if isSessionExtendRequired == true {
            
            LoggerAgent.shared.log(category: .session, message: "sent SessionAgentAction.Session.Extend")
            self.action.send(SessionAgentAction.Session.Extend())
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
