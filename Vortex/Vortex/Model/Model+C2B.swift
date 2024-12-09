//
//  Model+C2B.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 28.07.2023.
//

import Foundation
import ServerAgent

extension ModelAction {
    
    enum C2B {
        
        enum GetC2BSubscription {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let data: C2BSubscription
            }
        }
        
        enum GetC2BDetail {
            
            struct Request: Action {
                
                let token: String
            }
            
            struct Response: Action {
                
                let params: [PaymentsParameterRepresentable]
            }
        }
        
        enum CancelC2BSub {
            
            struct Request: Action {
                
                let token: String
            }
            
            struct Response: Action {
                
                let data: C2BSubscriptionData
            }
        }
        
        enum UpdateC2BSub {
            
            struct Request: Action {
                
                let token: String
                let productId: ProductData.ID
            }
            
            struct Response: Action {
                
                let data: C2BSubscriptionData
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    func handler<Command: ServerCommand, Data>(
        makeCommand: @escaping (String) -> Command,
        map: @escaping (Command.Response) -> Data,
        consume: @escaping (Data) -> Void
    ) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = makeCommand(token)
        
        serverAgent.executeCommand(command: command) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .success(response):
                
                switch response.statusCode {
                case .ok:
                    
                    guard let _ = response.data else {
                        handleServerCommandEmptyData(command: makeCommand(token))
                        return
                    }
                    
                    consume(map(response))
                    
                default:
                    handleServerCommandStatus(command: command, serverStatusCode: response.statusCode, errorMessage: response.errorMessage)
                }
                
            case let .failure(error):
                handleServerCommandError(error: error, command: command)
            }
        }
    }
    
    func handleGetC2BSubscription(_ payload: ModelAction.C2B.GetC2BSubscription.Request) {
        
        let makeCommand = { (token: String) in
            
            ServerCommands.SubscriptionController.GetC2bSubscriptions(
                token: token,
                payload: .init()
            )
        }
        
        handler(makeCommand: makeCommand, map: { response in
            
            guard let data = response.data else {
                return []
            }
            
            self.subscriptions.value = data
            
            var icons: [String] = []
            
            if let list = data.list {
                
                for item in list {
                    
                    item.subscriptions.forEach { sub in
                        
                        icons.append(sub.brandIcon)
                    }
                }
            }
            
            return icons
            
        }) { icons in
            
            self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: icons))
            
        }
    }
    
    func handleGetC2BSubscriptionDetail(_ payload: ModelAction.C2B.GetC2BDetail.Request) {
        
        let makeCommand = { (token: String) in
            
            ServerCommands.SubscriptionController.GetC2bDetailSubscriptions(
                token: token,
                payload: .init(subscriptionToken: payload.token)
            )
        }
        
        handler(makeCommand: makeCommand, map: { response in
            
            guard let data = response.data else {
                return []
            }
            
            if var params = try? self.paymentsC2BReduceScenarioData(
                data: data.parameters,
                c2b: .success
            ) {
                
                params.append(Payments.ParameterHidden(
                    id: Payments.Parameter.Identifier.successSubscriptionToken.rawValue,
                    value: data.subscriptionToken)
                )
                
                return params
            } else {
                
                return []
            }
                        
        }) { params in
            
            self.action.send(ModelAction.C2B.GetC2BDetail.Response(params: params))
        }
    }
    
    func handleCancelC2BSubscription(_ payload: ModelAction.C2B.CancelC2BSub.Request) {
        
        let makeCommand = { (token: String) in
            
            ServerCommands.SubscriptionController.CancelC2bSubscriptions(
                token: token,
                payload: .init(subscriptionToken: payload.token)
            )
        }
        
        handler(makeCommand: makeCommand, map: { response in
            
            return response.data
            
        }) { data in
            
            guard let data = data else {
                return
            }
            
            self.action.send(ModelAction.C2B.CancelC2BSub.Response(data: data))
        }
    }
    
    func handleUpdateC2BSubscriptionCard(_ payload: ModelAction.C2B.UpdateC2BSub.Request) {
        
        guard let product = self.product(productId: payload.productId) else { return }
        
        let makeCommand = { (token: String) in
            
            ServerCommands.SubscriptionController.UpdateC2bSubscriptionCard(
                token: token,
                payload: .init(
                    subscriptionToken: token,
                    productId: product.id
                )
            )
        }
        
        handler(makeCommand: makeCommand, map: { response in
            
            return response.data
            
        }) { data in
            
            guard let data = data else {
                return
            }
            
            self.action.send(ModelAction.C2B.UpdateC2BSub.Response(data: data))
        }
    }
    
    func handleUpdateC2BSubscriptionAcc(_ payload: ModelAction.C2B.UpdateC2BSub.Request) {
        
        guard let product = self.product(productId: payload.productId) else { return }
        
        let makeCommand = { (token: String) in
            
            ServerCommands.SubscriptionController.UpdateC2bSubscriptionAcc(
                token: token,
                payload: .init(
                    subscriptionToken: token,
                    productId: product.id
                )
            )
        }
        
        handler(makeCommand: makeCommand, map: { response in
            
            return response.data
            
        }) { data in
            
            guard let data = data else {
                return
            }
            
            self.action.send(ModelAction.C2B.UpdateC2BSub.Response(data: data))
        }
    }
}
