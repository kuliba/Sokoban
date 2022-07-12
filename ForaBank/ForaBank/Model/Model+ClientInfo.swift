//
//  Model+ClientInfo.swift
//  ForaBank
//
//  Created by Max Gribov on 26.05.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum ClientInfo {
        
        enum Fetch {
        
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<ClientInfoData, Error>
            }
        }
    }
    
    enum ClientPhoto {
        
        struct Save: Action {
            
            let image: ImageData
        }
        
        struct Delete: Action { }
    }
    
    enum ClientName {
        
        struct Save: Action {
            
            let name: String?
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleClientInfoFetchRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PersonController.GetClientInfo(token: token)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    
                    guard let clientInfo = response.data else {
                        
                        self.action.send(ModelAction.ClientInfo.Fetch.Response(result: .failure(ModelClientInfoError.emptyData(message: response.errorMessage))))
                        return
                    }

                    self.clientInfo.value = clientInfo
                    self.action.send(ModelAction.ClientInfo.Fetch.Response(result: .success(clientInfo)))
                    
                    // cache
                    do {
                        
                        try self.localAgent.store(clientInfo, serial: nil)
                        
                    } catch {
                        
                        //TODO: log error
                        print("handleClientInfoFetchRequest: caching error: \(error.localizedDescription)")
                    }
                    
                default:
                    self.action.send(ModelAction.ClientInfo.Fetch.Response(result: .failure(ModelClientInfoError.statusError(status: response.statusCode, message: response.errorMessage))))
                }
                
            case .failure(let error):
                self.action.send(ModelAction.ClientInfo.Fetch.Response(result: .failure(ModelClientInfoError.serverCommandError(error: error))))
            }
        }
    }
    
    func handleClientPhotoRequest(_ payload: ModelAction.ClientPhoto.Save) {
        
        clientPhoto.value = payload.image
        
        do {
            
            try localAgent.store(payload.image, serial: nil)
            
        } catch {
            
            print("Model: store: ClientPhotoData error: \(error.localizedDescription)")
        }
    }
    
    func handleMediaDeleteAvatarRequest() {
        self.clientPhoto.value = nil
        
        do {
            
            try localAgent.clear(type: ImageData.self)
            
        } catch {
            
            print("Model: store: ClientNameData error: \(error.localizedDescription)")
        }
    }
    
    func handleClientNameSave(_ payload: ModelAction.ClientName.Save) {
        
        clientName.value = payload.name
        
        if let name = payload.name {
            do {
                
                try localAgent.store(name, serial: nil)
                
            } catch {
                
                print("Model: store: ClientNameData error: \(error.localizedDescription)")
            }
        } else {
            
            do {
                
                try localAgent.clear(type: String.self)
                
            } catch {
                
                print("Model: store: ClientNameData error: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - Error

enum ModelClientInfoError: Swift.Error {
    
    case emptyData(message: String?)
    case statusError(status: ServerStatusCode, message: String?)
    case serverCommandError(error: Error)
    case cacheError(Error)
}
