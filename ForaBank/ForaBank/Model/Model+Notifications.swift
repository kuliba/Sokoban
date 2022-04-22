//
//  Model+Notifications.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.04.2022.
//

import Foundation

extension Model {
    
    
    func handleNotificationsNewRequest() {
        guard let token = token else {
            return
        }
        
        let command = ServerCommands.NotificationController.GetNotifications(token: token, offset: 0, limit: 100, types: [.push, .sms, .email], states: [.new, .inProgress, .sent, .error, .delivered, .read])
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let notifications = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return }
                    
                    
                default:
                    //TODO: handle not ok server status
                    return
                }
            case .failure(let error):
                self.action.send(ModelAction.Settings.GetClientInfo.Failed(error: error))
            }
        }
    }
    
    func handleNotificationsNextRequest() {
        guard let token = token else {
            return
        }
        
        let offset = notifications.value.count
        
        let command = ServerCommands.NotificationController.GetNotifications(token: token, offset: offset, limit: 100, types: [.push, .sms, .email], states: [.new, .inProgress, .sent, .error, .delivered, .read])
        
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let notifications = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return }
                    
                default:
                    //TODO: handle not ok server status
                    return
                }
            case .failure(let error):
                self.action.send(ModelAction.Settings.GetClientInfo.Failed(error: error))
            }
        }
    }
}
