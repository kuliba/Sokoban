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
        
        struct GetUserSettings: Action {}
        
        struct UpdateUserSettingPush: Action {

            let userSetting: UserSettingPush
        }
        
        enum ApplicationSettings {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<AppSettings, Error>
            }
        }
    }
}

//MARK: - Data Helpers

extension Model {
    
    var settingsLaunchedBefore: Bool {
        
        do {
            
            let launchedBefore: Bool = try settingsAgent.load(type: .general(.launchedBefore))
            return launchedBefore
            
        } catch {
            
            return false
        }
    }
    
    var settingsMainSections: MainSectionsSettings {
        
        do {
    
            let settings: MainSectionsSettings = try settingsAgent.load(type: .interface(.mainSections))
            return settings
        
        } catch {
            
            return MainSectionsSettings(collapsed: [:])
        }
    }
    
    var settingsMyProductsOnboarding: MyProductsOnboardingSettings {
        
        do {
    
            let settings: MyProductsOnboardingSettings = try settingsAgent.load(type: .interface(.myProductsOnboarding))
            return settings
        
        } catch {
            
            return MyProductsOnboardingSettings(isOpenedView: false,
                                                isOpenedReorder: false,
                                                isHideOnboardingShown: false)
        }
        
    }
    
    var settingsProductsSections: ProductsSectionsSettings {
        
        do {
    
            let settings: ProductsSectionsSettings = try settingsAgent.load(type: .interface(.productsSections))
            return settings
        
        } catch {
            
            return ProductsSectionsSettings(collapsed: [:])
        }
    }
    
    var settingsProductsMoney: ProductsMoneySettings {
        
        do {
    
            let settings: ProductsMoneySettings = try settingsAgent.load(type: .interface(.productsMoney))
            return settings
        
        } catch {
            
            return ProductsMoneySettings(selectedCurrencyId: "RUB",
                                         selectedCurrencySymbol: "\u{20BD}")
        }
    }
    
    func settingsMainSectionsUpdate(_ settings: MainSectionsSettings) {
        
        do {
            
            try settingsAgent.store(settings, type: .interface(.mainSections))
            
        } catch {
            
            //TODO: set logger
        }
    }
    
    func settingsProductsSectionsUpdate(_ settings: ProductsSectionsSettings) {
        
        do {
            
            try settingsAgent.store(settings, type: .interface(.productsSections))
            
        } catch {
            
            //TODO: set logger
        }
    }
    
    func settingsMyProductsOnboardingUpdate(_ settings: MyProductsOnboardingSettings) {
        
        do {
            
            try settingsAgent.store(settings, type: .interface(.myProductsOnboarding))
            
        } catch {
            
            //TODO: log
            print(error.localizedDescription)
        }
    }
    
    func settingsProductsMoneyUpdate(_ settings: ProductsMoneySettings) {
        
        do {
            
            try settingsAgent.store(settings, type: .interface(.productsMoney))
            
        } catch {
            
            //TODO: log
            print(error.localizedDescription)
        }
    }
    
    func userSetting<Setting: UserSettingProtocol>(for type: UserSettingData.Kind) -> Setting? {

        guard let setting = self.userSettings.value.filter({$0.sysName == type.rawValue}).first else { return nil }

        switch type {
        case .disablePush:
            return UserSettingPush(with: setting) as? Setting
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handleUpdateUserSetting(_ payload: ModelAction.Settings.UpdateUserSettingPush) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        let command = ServerCommands.UserController.SetUserSetting(token: token, userSetting: payload.userSetting)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                    
                switch response.statusCode {
                case .ok:
                    
                    let reducedSettings = Self.reduceSettings(userSettings: self.userSettings.value, data: payload.userSetting.userSettingData)
                    self.userSettings.value = reducedSettings
                    
                    do {
                            
                        try self.localAgent.store(reducedSettings, serial: nil)

                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    if let errorMessage = response.errorMessage {
                        
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)
                    } else {
                        
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: nil)
                    }
                }
                
            case .failure(let error):
                
                self.handleServerCommandError(error: error, command: command)

            }
        }
    }
    
    func handleGetUserSettings() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        let command = ServerCommands.UserController.GetUserSettings(token: token)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                    
                switch response.statusCode {
                case .ok:
                    
                    guard let settings = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.userSettings.value = settings.userSettingList
                    
                    do {
                            
                        try self.localAgent.store(settings.userSettingList, serial: nil)

                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }
                    
                default:
                    
                    if let errorMessage = response.errorMessage {
                        
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)
                    } else {
                        
                        self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: nil)
                    }
                }
                
            case .failure(let error):
                
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleAppSettingsRequest() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.SettingsController.GetAppSettings(token: token)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let response):
                
                switch response.statusCode {
                case .ok:
                    
                    guard let settings = response.data else {
                        self.handleServerCommandEmptyData(command: command)
                        return
                    }
                    
                    self.action.send(ModelAction.Settings.ApplicationSettings.Response(result: .success(settings.appSettings)))
                    
                default:
                    
                    self.action.send(ModelAction.Settings.ApplicationSettings.Response(result: .failure(ModelError.statusError(status: response.statusCode, message: response.errorMessage))))
                    
                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case .failure(let error):
                self.action.send(ModelAction.Settings.ApplicationSettings.Response(result: .failure(error)))
                self.handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    static func reduceSettings(userSettings: [UserSettingData], data: UserSettingData) -> [UserSettingData] {
        
        var settings = [UserSettingData]()
        
        for setting in userSettings {
            
            if setting.sysName == data.sysName {
                
                settings.append(data)
                
            } else {
                
                settings.append(setting)
            }
        }
        
        let settingsNames = settings.map{ $0.sysName }
        if !settingsNames.contains(data.sysName) {

            settings.append(data)
        }

        return settings
    }
}
