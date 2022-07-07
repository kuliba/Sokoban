//
//  SessionAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 20.04.2022.
//

import Foundation
import Combine

class SessionAgent: SessionAgentProtocol {
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let action: PassthroughSubject<Action, Never>
    let sessionState: CurrentValueSubject<SessionState, Never>
    
    private var sessionDuration: TimeInterval
    private var lastNetworkActivityTime: TimeInterval
    private var lastUserActivityTime: TimeInterval
    private var sessionExtentThreshold: Double
    
    private var bindings = Set<AnyCancellable>()

    init(sessionDuration: TimeInterval = 300, sessionExtentThreshold: Double = 0.7) {
        
        self.action = .init()
        self.sessionState = .init(.inactive)
        self.sessionDuration = sessionDuration
        self.lastNetworkActivityTime = Date.distantPast.timeIntervalSinceReferenceDate
        self.lastUserActivityTime = Date.distantPast.timeIntervalSinceReferenceDate
        self.sessionExtentThreshold = sessionExtentThreshold
        
        bind()
    }
    
    func bind() {
        
        timer
            .map{ date in date.timeIntervalSinceReferenceDate }
            .sink {[unowned self] time in
                
                guard case .active(_, _) = sessionState.value else {
                    return
                }
                
                let sessionTimeRemain = sessionTimeRemain(for: time)
                guard sessionTimeRemain > 0 else {
                    
                    sessionState.send(.expired)
                    return
                }
                
                if isSessionExtendRequired(for: sessionTimeRemain) == true {
                    
                    action.send(SessionAgentAction.Session.Extend.Request())
                }
                
                print("SessionAgent: remain time: \(sessionTimeRemain)")
  
            }.store(in: &bindings)
        
        action
            .sink { [unowned self] action in
            
                switch action {
                case let payload as SessionAgentAction.Session.Start.Response:
                    switch payload.result {
                    case .success(let credentials):
                        let start = Date.timeIntervalSinceReferenceDate
                        sessionState.send(.active(start: start, credentials: credentials))
                        updateLastNetworkActivityTime()
                        self.action.send(SessionAgentAction.Session.Extend.Request())
                        print("SessionAgent: session: STARTED")
                        
                    case .failure(let error):
                        sessionState.send(.failed(error))
                    }
                    
                case let payload as SessionAgentAction.Session.Extend.Response:
                    switch payload.result {
                    case .success(let duration):
                        sessionDuration = duration
                        updateLastNetworkActivityTime()
                        print("SessionAgent: session: EXTENDED")
                        
                    case .failure(let error):
                        sessionState.send(.failed(error))
                    }
                    
                case _ as SessionAgentAction.Event.Network:
                    print("SessionAgent: NETWORK EVENT")
                    updateLastNetworkActivityTime()
                    
                case _ as SessionAgentAction.Event.UserInteraction:
                    print("SessionAgent: UI EVENT")
                    updateLastUserActivityTime()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        sessionState
            .sink { [unowned self] state in
                
                switch state {
                case .inactive:
                    print("SessionAgent: state: INACTIVE")
                    
                case .active:
                    print("SessionAgent: state: ACTIVE")
                    
                case .expired:
                    print("SessionAgent: state: EXPIRED")
                    
                case .failed:
                    print("SessionAgent: state: FAILED")
                }
                
            }.store(in: &bindings)
    }
    
    func sessionTimeRemain(for time: TimeInterval) -> TimeInterval {
        
        let timeSinceLastNetworkActivity = time - lastNetworkActivityTime
        
        return max(sessionDuration - timeSinceLastNetworkActivity, 0)
    }
    
    func isSessionExtendRequired(for sessionTimeRemain: TimeInterval) -> Bool {
        
        return Double(sessionTimeRemain / sessionDuration) < (1 - sessionExtentThreshold) && lastUserActivityTime > lastNetworkActivityTime
    }
    
    func updateLastNetworkActivityTime() {
        
        lastNetworkActivityTime = Date().timeIntervalSinceReferenceDate
    }
    
    func updateLastUserActivityTime() {
        
        lastUserActivityTime = Date().timeIntervalSinceReferenceDate
    }
}
