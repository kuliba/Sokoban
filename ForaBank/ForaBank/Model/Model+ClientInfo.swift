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
        
        enum Delete {
            
            struct Request: Action {}
            
            enum Response: Action {
                
                case success
                case failure(Error)
            }
            
        }
    }
    
    enum ClientPhoto {
        
        struct Load: Action { }
        
        struct Save: Action {
            
            let image: ImageData
        }
        
        struct Delete: Action { }
    }
    
    enum ClientName {
        
        struct Save: Action {
            
            let name: String?
        }
        
        enum Get {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<ServerCommands.PersonController.GetPerson.Response.PersonData, Error>
            }
        }
        
        struct Delete: Action {}
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
                    self.clientName.value = .init(name: clientInfo.customName ?? clientInfo.firstName)
                    self.action.send(ModelAction.ClientInfo.Fetch.Response(result: .success(clientInfo)))
                    
                    // cache
                    do {
                        
                        try self.localAgent.store(clientInfo, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    self.action.send(ModelAction.ClientInfo.Fetch.Response(result: .failure(ModelClientInfoError.statusError(status: response.statusCode, message: response.errorMessage))))
                    if let errorMessage = response.errorMessage {

                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)
                    } else {
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: nil)
                    }
                }
                
            case .failure(let error):
                self.action.send(ModelAction.ClientInfo.Fetch.Response(result: .failure(ModelClientInfoError.serverCommandError(error: error))))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    
    func handleClientPhotoSave(_ payload: ModelAction.ClientPhoto.Save) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        guard let image = payload.image.uiImage else { return }
        
        guard let imageData: ImageData = .init(with: image) else { return }
        
        guard let mediaParameter: ServerCommandMediaParameter = .init(with: imageData, fileName: image.hashValue.description) else { return }
        
        let command = ServerCommands.PersonController.UpdatePersonImage(token: token, media: mediaParameter)
        
        serverAgent.executeUploadCommand(command: command) {[self] result in

            switch result {
            case .success(let response):
                    
                switch response.statusCode {
                case .ok:
                    
                    let clientPhotoData = ClientPhotoData(photo: payload.image)
                    clientPhoto.value = clientPhotoData

                    do {
                        
                        try localAgent.store(clientPhotoData, serial: nil)
                        
                    } catch {
                        //TODO: added handler for upload command
                        print("Model: handleClientPhotoSave error: \(error.localizedDescription)")
                    }
                    
                default:
                    //TODO: added handler for upload command
                    break
                    
                }
                
            case .failure(let error):
                //TODO: added handler for upload command
                print("Model: handleClientPhotoSave error: \(error)")

            }
        }
    }
    
    func handleClientPhotoRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PersonController.GetPersonImage(token: token)
        serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                
                guard data.count != 0 else {
                    return
                }
                
                let clientPhotoData = ClientPhotoData(photo: .init(data: data))
                clientPhoto.value = clientPhotoData

                do {
                    
                    try localAgent.store(clientPhotoData, serial: nil)
                    
                } catch {
                    //TODO: added handler for download command
                    print("Model: store: ClientPhotoData error: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                //TODO: added handler for download command
                print("Model: store: ClientPhotoData error: \(error)")
            }
        }
    }
    
    func handleMediaDeleteAvatarRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PersonController.RemovePersonImage(token: token)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(_):

                self.clientPhoto.value = nil
                
                do {
                    
                    try localAgent.clear(type: ClientPhotoData.self)
                    
                } catch {
                    
                    self.handleServerCommandCachingError(error: error, command: command)
                }
                
            case .failure(let error):
                
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleClientNameSave(_ payload: ModelAction.ClientName.Save) {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        guard let name = payload.name else { return }
        
        let command = ServerCommands.PersonController.SetPersonCustomName(token: token, payload: .init(customName: name))
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(_):

                self.action.send(ModelAction.ClientInfo.Fetch.Request())
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleClientNameLoad() {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PersonController.GetPerson(token: token)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):

                    let clientNameData = ClientNameData(name: data.data.firstname)
                    clientName.value = clientNameData
                    
                    do {
                        
                        try localAgent.store(clientNameData, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleClientNameDelete() {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PersonController.RemovePersonCustomName(token: token)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(_):

                clientName.value = nil
                self.action.send(ModelAction.ClientName.Get.Request())
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleClientInfoDelete() {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PersonController.DeleteAllPersonProperties(token: token)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(_):
                self.action.send(ModelAction.ClientInfo.Delete.Response.success)
                
            case .failure(let error):
                self.handleServerCommandError(error: error, command: command)
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
