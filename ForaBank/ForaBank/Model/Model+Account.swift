//
//  Model+Account.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.06.2022.
//

import Foundation

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

        action.send(ModelAction.Account.Informer.Show(message: "\(payload.currencyName) счет открывается"))

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

                    self.action.send(ModelAction.Account.Informer.Show(message: "\(payload.currencyName) счет открыт"))
                    self.action.send(ModelAction.Account.MakeOpenAccount.Response.complete(data))

                default:
                    let errorMessage = response.errorMessage

                    self.handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: errorMessage)

                    self.action.send(ModelAction.Account.MakeOpenAccount.Response.failed(error: .statusError(status: response.statusCode, message: errorMessage)))
                }

            case let .failure(error):
                self.handleServerCommandError(error: error, command: command)
                self.action.send(ModelAction.Account.MakeOpenAccount.Response.failed(error: .serverCommandError(error: error.localizedDescription)))
            }
        }
    }
}

// MARK: - Reset

extension Model {

    func handleMakeOpenAccountUpdate(payload: ModelAction.Account.MakeOpenAccount.Response) {

        switch payload {
        case .complete:

            // Обновление открытых счетов на главном экране
            action.send(ModelAction.Products.Update.ForProductType(productType: .account))

            // Обновление списка счетов
            action.send(ModelAction.Account.ProductList.Request())

            // Скрыть уведомление об открытии счета через 4 сек
            action.send(ModelAction.Account.Informer.Dismiss(after: 4))

        case .failed(error: let error):
            
            let time = accountInformerDismissTime(error: error)
            
            // Скрыть уведомление об открытии счета:
            // - некорректный код - через 0 сек
            // - исчерпали все попытки - 0 сек
            // - время для ввода истекло - 0 сек
            
            action.send(ModelAction.Account.Informer.Dismiss(after: time))
        }
    }
    
    func accountInformerDismissTime(error: Model.ProductsListError) -> TimeInterval {
        
        let rawValue = accountRawResponse(error: error)
        
        switch rawValue {
        default:
            return 0
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
    
    func accountRawResponse(error: Model.ProductsListError) -> OpenAccountRawResponse {
        
        guard let rawValue = OpenAccountRawResponse(rawValue: messageError(error: error)) else {
            return .none
        }
        
        return rawValue
    }
}

// MARK: - Informer

extension Model {

    func handleInformerShow(payload: ModelAction.Account.Informer.Show) {
        informer.value = .init(message: payload.message)
    }

    func handleInformerDismiss(payload: ModelAction.Account.Informer.Dismiss) {

        DispatchQueue.main.asyncAfter(deadline: .now() + payload.after) {
            self.informer.value = nil
        }
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
                let currencyName: String
                let currencyCode: Int
            }

            enum Response: Action {

                case complete(OpenAccountMakeData)
                case failed(error: Model.ProductsListError)
            }
        }

        enum Informer {

            struct Show: Action {

                let message: String
            }

            struct Dismiss: Action {

                let after: TimeInterval
            }
        }
    }
}
