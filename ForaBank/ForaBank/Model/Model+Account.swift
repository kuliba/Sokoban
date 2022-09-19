//
//  Model+Account.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.06.2022.
//

import SwiftUI

// MARK: - Handlers

extension Model {

    /// Получение списка описаний счета
    func handleAccountProductsListUpdate() {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        let command = ServerCommands.AccountController.GetAccountProductList(token: token)
        let productsListError = ProductsListError.emptyData(message: ProductsListError.errorMessage)

        serverAgent.executeCommand(command: command) { result in

            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:

                    guard let accountProductsList = response.data else {

                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Account.ProductList.Response.failed(error: productsListError))

                        return
                    }

                    self.accountProductsList.value = accountProductsList

                    do {
                        
                        try self.localAgent.store(accountProductsList, serial: nil)
                        
                    } catch {
                        
                        self.handleServerCommandCachingError(error: error, command: command)
                    }

                default:

                    let errorMessage = response.errorMessage

                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)

                    self.action.send(ModelAction.Account.ProductList.Response.failed(error: .statusError(status: response.statusCode, message: errorMessage)))
                }

            case let .failure(error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Account.ProductList.Response.failed(error: .serverCommandError(error: error.localizedDescription)))
            }
        }
    }

    /// Подготовка операции для открытия нового счета и отправка OTP
    func handlePrepareOpenAccount() {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        let command = ServerCommands.AccountController.GetPrepareOpenAccount(token: token)
        let productsListError = ProductsListError.emptyData(message: ProductsListError.errorMessage)

        serverAgent.executeCommand(command: command) { result in

            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:

                    guard let data = response.data else {

                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Account.PrepareOpenAccount.Response.failed(error: productsListError))

                        return
                    }

                    self.action.send(ModelAction.Account.PrepareOpenAccount.Response.complete(data))

                default:

                    let errorMessage = response.errorMessage

                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)

                    self.action.send(ModelAction.Account.PrepareOpenAccount.Response.failed(error: .statusError(status: response.statusCode, message: errorMessage)))
                }

            case let .failure(error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Account.PrepareOpenAccount.Response.failed(error: .serverCommandError(error: error.localizedDescription)))
            }
        }
    }

    /// Проверка OTP и открытие нового счета
    func handleMakeOpenAccount(_ payload: ModelAction.Account.MakeOpenAccount.Request) {

        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }

        let command = ServerCommands.AccountController.GetMakeOpenAccount(
            token: token,
            payload: .init(
                cryptoVersion: "1.0",
                verificationCode: payload.verificationCode,
                currencyCode: payload.currencyCode))
        let productsListError = ProductsListError.emptyData(message: ProductsListError.errorMessage)

        accountOpening.value = true
        action.send(ModelAction.Informer.Show(informer: .init(message: "\(payload.currency.description) счет открывается", icon: .refresh, type: .openAccount)))
        
        serverAgent.executeCommand(command: command) { result in

            switch result {
            case let .success(response):
                switch response.statusCode {
                case .ok:

                    guard let data = response.data else {

                        self.handleServerCommandEmptyData(command: command)
                        self.action.send(ModelAction.Account.MakeOpenAccount.Response.failed(error: productsListError))

                        return
                    }

                    self.accountOpening.value = false
                    self.action.send(ModelAction.Informer.Show(informer: .init(message: "\(payload.currency.description) счет открыт", icon: .check)))
                    
                    self.action.send(ModelAction.Account.MakeOpenAccount.Response.complete(data))

                default:
                    let errorMessage = response.errorMessage

                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)
                    
                    self.action.send(ModelAction.Account.MakeOpenAccount.Response.failed(error: .statusError(status: response.statusCode, message: errorMessage)))
                    
                    self.accountOpening.value = false
                    
                    if let errorMessage = errorMessage, OpenAccountRawResponse(rawValue: errorMessage) == nil {
                        
                        self.action.send(ModelAction.Informer.Show(informer: .init(message: "\(payload.currency.description) счет не открыт", icon: .close)))
                        
                    } else {
                        
                        self.action.send(ModelAction.Informer.Dismiss(type: .openAccount))
                    }
                }

            case let .failure(error):
                
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Account.MakeOpenAccount.Response.failed(error: .serverCommandError(error: error.localizedDescription)))
                
                self.accountOpening.value = false
                self.action.send(ModelAction.Informer.Show(informer: .init(message: "\(payload.currency.description) счет не открыт", icon: .close)))
            }
        }
    }
}

// MARK: - Update

extension Model {

    func handleMakeOpenAccountUpdate(payload: ModelAction.Account.MakeOpenAccount.Response) {
        
        if case .complete = payload {
            
            // Обновление открытых счетов на главном экране
            action.send(ModelAction.Products.Update.ForProductType(productType: .account))
            
            // Обновление списка счетов
            action.send(ModelAction.Account.ProductList.Request())
        }
    }
    
    func messageError(error: Model.ProductsListError) -> String {
        
        var messageError = ""
        
        switch error {
        case .emptyData(message: let message):
            
            guard let message = message else {
                return ""
            }
            
            messageError = message
            
        case let .statusError(_, message: message):
            
            guard let message = message else {
                return ""
            }
            
            messageError = message

        case .serverCommandError(error: let error):
            messageError = error
            
        default:
            break
        }
        
        return messageError
    }
    
    func accountRawResponse(error: Model.ProductsListError) -> OpenAccountRawResponse? {
        
        let rawValue = OpenAccountRawResponse(rawValue: messageError(error: error))
        
        guard let rawValue = rawValue else {
            return nil
        }
        
        return rawValue
    }
}

// MARK: - Cache

extension Model {

    func productsListCacheLoadData() -> [OpenAccountProductData]? {

        localAgent.load(type: [OpenAccountProductData].self)
    }

    func productsListCacheClearData() throws  {

        do {
            try localAgent.clear(type: [OpenAccountProductData].self)
        } catch {
            throw ProductsListError.clearCacheErrors(error)
        }
    }
}

// MARK: - Error

extension Model {

    enum ProductsListError: Swift.Error {

        static let errorMessage = "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения."

        case emptyData(message: String?)
        case statusError(status: ServerStatusCode, message: String?)
        case serverCommandError(error: String)
        case unableCacheUnknownProductType
        case clearCacheErrors(Error)
    }
}

// MARK: - Actions

extension ModelAction {

    enum Account {

        enum ProductList {

            struct Request: Action {}

            enum Response: Action {

                case complete
                case failed(error: Model.ProductsListError)
            }
        }

        enum PrepareOpenAccount {

            struct Request: Action {}

            enum Response: Action {

                case complete(OpenAccountPrepareData)
                case failed(error: Model.ProductsListError)
            }
        }

        enum MakeOpenAccount {

            struct Request: Action {

                let verificationCode: String
                let currency: Currency
                let currencyCode: Int
            }

            enum Response: Action {

                case complete(OpenAccountMakeData)
                case failed(error: Model.ProductsListError)
            }
        }
    }
}
