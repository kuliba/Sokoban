//
//  Model+Notifications.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.04.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Notification {
        
        enum Fetch {
            
            enum New {
                
                struct Request: Action {}
                
                struct Response: Action {
                    
                    let result: Result<[NotificationData], Error>
                }
            }
            
            enum Next {
                
                struct Request: Action {}
                
                struct Response: Action {
                    
                    let result: Result<[NotificationData], Error>
                }
            }
        }
        
        enum ChangeNotificationStatus {
            
            struct Request: Action {
                
                let statusData: NotificationStatusData
            }
            
            enum Response: Action {
                
                case sussesed
                case failed(Error)
            }
        }
        
        enum Transition {
            
            struct Set: Action {
                
                let transition: NotificationTransition
            }
            
            struct Process: Action {
               
                let transition: NotificationTransition
            }
            
            struct Clear: Action {}
        }
    }
}

//MARK: - Handlers

extension Model {
    
    static func dictinaryNotificationReduce(current: [NotificationData], update: [NotificationData]) -> [NotificationData] {
        
        let resultSet = Set(current).union(update)
        return Array(resultSet).sorted(by: { $0.date < $1.date })
    }
    
    func handleNotificationTransitionSet(payload: ModelAction.Notification.Transition.Set) {

        notificationsTransition = payload.transition
        
        if auth.value == .authorized {
            
            action.send(ModelAction.Notification.Transition.Process(transition: payload.transition))
        }
    }

    func handleNotificationTransitionClear() {

        notificationsTransition = nil
    }
    
    func handleNotificationsFetchNewRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.NotificationController.GetNotifications(token: token, offset: 0, limit: 15, types: [.push, .sms, .email], states: [.new, .inProgress, .sent, .error, .delivered, .read])
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
                
            case .success(let response):
                
                switch response.statusCode {
                case .ok:
                    
                    guard let notifications = response.data else {
                        
                        self.handleServerCommandEmptyData(command: command)
                        
                        return }
                    
                    self.notifications.value = Self.dictinaryNotificationReduce(current: self.notifications.value, update: notifications)
                    
                    do {
                        
                        try self.localAgent.store(self.notifications.value, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandError(error: error, command: command)
                    }
                    
                    self.action.send(ModelAction.Notification.Fetch.New.Response(result: .success(notifications)))
                    
                default:
                    
                    //TODO: handle not ok server status
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    
                    return
                }
                
            case .failure(let error):
                self.action.send(ModelAction.Notification.Fetch.New.Response(result: .failure(error)))
            }
        }
    }
    
    func handleNotificationsFetchNextRequest() {
        
        guard let token = token else {
            
            handledUnauthorizedCommandAttempt()
            
            return
        }
        
        let offset = notifications.value.count
        
        let command = ServerCommands.NotificationController.GetNotifications(token: token, offset: offset, limit: 15, types: [.push, .sms, .email], states: [.new, .inProgress, .sent, .error, .delivered, .read])
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
                
            case .success(let response):
                
                switch response.statusCode {
                    
                case .ok:
                    
                    guard let notifications = response.data else {
                        
                        self.handleServerCommandEmptyData(command: command)
                        
                        return }
                    
                    self.notifications.value = Self.dictinaryNotificationReduce(current: self.notifications.value, update: notifications)
                    
                    do {
                        
                        try self.localAgent.store(self.notifications.value, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandError(error: error, command: command)
                    }
                    
                    self.action.send(ModelAction.Notification.Fetch.Next.Response(result: .success(notifications)))
                    
                default:
                    
                    //TODO: handle not ok server status
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                    
                    return
                }
                
            case .failure(let error):
                self.action.send(ModelAction.Notification.Fetch.Next.Response(result: .failure(error)))
            }
        }
    }
    
    func handleNotificationsChangeNotificationStatusRequest(payload: ModelAction.Notification.ChangeNotificationStatus.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.NotificationController.ChangeNotificationStatus (token: token, payload: .init(eventId: payload.statusData.eventId, cloudId: payload.statusData.cloudId, status: payload.statusData.status))
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    self.action.send(ModelAction.Notification.ChangeNotificationStatus.Response.sussesed)
                default:
                    //TODO: handle not ok server status
                    return
                }
            case .failure(let error):
                self.action.send(ModelAction.Notification.ChangeNotificationStatus.Response.failed(error))
            }
        }
    }
}
