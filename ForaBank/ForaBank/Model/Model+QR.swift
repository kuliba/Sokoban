//
//  Model+QR.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.11.2022.
//

import Foundation

extension ModelAction {
    
    enum QRAction {
        
        enum GetPaymentsMapping {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<QRMapping, Error>
            }
        }
        
        enum SetQRFailData {
            
            struct Request: Action {
                
                let failData: QRMapping.FailData
            }
            
            struct Response: Action {
                
                let result: Result<EmptyData, Error>
            }
        }
    }
}

//MARK: - Handlers

extension Model {
 
    func handleGetPaymentsMapping(_ serial: String?) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
//        let command = ServerCommands.QRController.GetPaymentsMapping(token: token, serial: serial)
//
//        serverAgent.executeCommand(command: command) { result in
//
//            switch result {
//
//            case .success(let response):
//
//                switch response.statusCode {
//                case .ok:
//
//                    guard let qrData = response.data else {
//
//                        self.handleServerCommandEmptyData(command: command)
//
//                        return }
//
//                    self.qrDictionary.value = qrData.qrMapping
//
//                    do {
//
//                        try self.localAgent.store(qrData.qrMapping, serial: qrData.serial)
//
//                    } catch {
//
//                        self.handleServerCommandError(error: error, command: command)
//                    }
//
//                    self.action.send(ModelAction.QRAction.GetPaymentsMapping.Response(result: .success(qrData.qrMapping)))
//
//                default:
//
//                    //TODO: handle not ok server status
//                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
//
//                    return
//                }
//
//            case .failure(let error):
//                self.action.send(ModelAction.QRAction.GetPaymentsMapping.Response(result: .failure(error)))
//            }
//        }
    }
    
    func handleSetQRFailData(_ failData: QRMapping.FailData) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
//        let command = ServerCommands.QRController.SetQRFailData(token: token, payload: failData)
//
//        serverAgent.executeCommand(command: command) { result in
//
//            switch result {
//
//            case .success(let response):
//
//                switch response.statusCode {
//                case .ok:
//
//                    guard let qrData = response.data else {
//
//                        self.handleServerCommandEmptyData(command: command)
//
//                        return }
//
//                    self.qrDictionary.value = qrData.qrMapping
//
//                    do {
//
//                        try self.localAgent.store(qrData.qrMapping, serial: qrData.serial)
//
//                    } catch {
//
//                        self.handleServerCommandError(error: error, command: command)
//                    }
//
//                    self.action.send(ModelAction.QRAction.GetPaymentsMapping.Response(result: .success(qrData.qrMapping)))
//
//                default:
//
//                    //TODO: handle not ok server status
//                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
//
//                    return
//                }
//
//            case .failure(let error):
//                self.action.send(ModelAction.QRAction.GetPaymentsMapping.Response(result: .failure(error)))
//            }
//        }
    }
}
