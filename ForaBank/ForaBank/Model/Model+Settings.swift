//
//  Model+Settings.swift
//  ForaBank
//
//  Created by Max Gribov on 24.03.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum Settings {
        
        enum GetClientInfo {
        
            struct Requested: Action { }
            
            struct Complete: Action {
                
                let user: ClientInfoData
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
    }
}

//MARK: - Data Helpers

extension Model {
    
    var settingsMainSections: MainSectionSettings {
        
        do {
    
            let settings: MainSectionSettings = try settingsAgent.load(type: .interface(.mainSections))
            return settings
        
        } catch {
            
            return .initial
        }
    }
    
    func settingsUpdate(_ settings: MainSectionSettings) {
        
        do {
            
            try settingsAgent.store(settings, type: .interface(.mainSections))
            
        } catch {
            
            //TODO: log
            print(error.localizedDescription)
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleGetClientInfoRequest() {
        guard let token = token else {
            return
        }
        
        let command = ServerCommands.PersonController.GetClientInfo(token: token)
        serverAgent.executeCommand(command: command) { result in
            
            switch result {
            case .success(let response):
                switch response.statusCode {
                case .ok:
                    guard let clientInfo = response.data else { return }
                    
                    //TODO: store settings
                    /*
                    do {
                        try self.settingsAgent.store(clientInfo, type: .personal(.allData))
                        
                    } catch {
                        
                        //TODO: log
                        print(error.localizedDescription)
                    }
                     */
                    
                    self.userSettingData.value = .authorized(user: clientInfo)
                    self.action.send(ModelAction.Settings.GetClientInfo.Complete(user: clientInfo))
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
