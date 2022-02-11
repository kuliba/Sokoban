//
//  Model+Payments.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

extension Model {
    
    typealias Category = Payments.Category
    typealias Service = Payments.Service
    typealias Operator = Payments.Operator
    typealias Parameter = Payments.Parameter
    typealias Operation = Payments.Operation
    
    //MARK: - Handlers
    
    func handlePaymentsServicesRequest(_ payload: ModelAction.Payment.Services.Request) {
        
        let services = payload.category.services.map{ serviceParameter(for: $0) }
        action.send(ModelAction.Payment.Services.Response(result: .success(services)))
    }
    
    func handlePaymentsBeginRequest(_ payload: ModelAction.Payment.Begin.Request) {
        
        switch payload.source {
        case .service(let service):
            
            operation(for: service, currency: payload.currency) { result in
                switch result {
                case .success(let operation):
                    self.action.send(ModelAction.Payment.Begin.Response(result: .success(operation)))
                    
                case .failure(let error):
                    self.action.send(ModelAction.Payment.Begin.Response(result: .failure(error)))
                }
            }
            
        case .templateId(let templateId):
            
            operation(for: templateId, currency: payload.currency) { result in
                
                switch result {
                case .success(let operation):
                    self.action.send(ModelAction.Payment.Begin.Response(result: .success(operation)))
                    
                case .failure(let error):
                    self.action.send(ModelAction.Payment.Begin.Response(result: .failure(error)))
                }
            }
        }
    }
    
    func handlePaymentsContinueRequest(_ payload: ModelAction.Payment.Continue.Request) {
        
        let operation = payload.operation
        let historyUpdated = operation.historyUpdated()
        parameters(for: operation.service, parameters: operation.parameters, history: historyUpdated) { result in
            
            //TODO: return data for confirm state
            
            switch result {
            case .success(let parameters):
                let continueOperation = Operation(service: operation.service, type: operation.type, currency: operation.currency, parameters: parameters, history: historyUpdated)
                self.action.send(ModelAction.Payment.Continue.Response(result: .step(continueOperation)))
                
            case .failure(let error):
                self.action.send(ModelAction.Payment.Continue.Response(result: .fail(error)))
            }
        }
    }
    
    func handlePaymentsCompleteRequest(_ payload: ModelAction.Payment.Complete.Request) {
        
        //TODO: make transfer
    }
    
    //MARK: - Operation
    
    func operation(for service: Service, currency: Currency, completion: @escaping (Result<Operation, Error>) -> Void){
        
        let serviceParameter = serviceParameter(for: service)
    
        parameters(for: service, parameters: [], history: [[]]) { result in
            
            switch result {
            case .success(let parameters):
                
                // operator must be selected
                guard let operatorParameter = parameters.first(where: { $0.id == Parameter.ID.operator.rawValue }) else {
                    completion(.failure(Payments.Error.unsupported))
                    return
                }
                
                // add operator selection to history
                let operatorValue = operatorParameter.parameterValue
                let operation = Operation(service: service, type: .service(title: serviceParameter.title, icon: serviceParameter.icon), currency: currency, parameters: parameters, history: [[operatorValue]])
                completion(.success(operation))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func operation(for tempaleId: PaymentTemplateData.ID, currency: Currency, completion: @escaping (Result<Operation, Error>) -> Void) {
        
        completion(.failure(Payments.Error.unsupported))
        
        //TODO: implementation required
        // - find template with id
        // - extract from template data:
        //      - payment service
        //      - create operation
    }
    
    //MARK: - Parameters
    
    func parameters(for service: Service, parameters: [Parameter], history: [[Parameter.Value]] , completion: @escaping (Result<[Parameter], Error>) -> Void) {
        
        let step = history.count
        
        switch service {
        case .fms:
            parametersFMS(parameters, step, completion)
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
    func serviceParameter(for service: Service) -> Parameter.Service {
        
        switch service {
        case .fns:
            return .init(service: service, icon: .serviceSample, title: "ФНС", description: "Налоги")
            
        case .fms:
            return .init(service: service, icon: .serviceSample, title: "ФМС", description: "Госпошлины")
    
        case .fssp:
            return .init(service: service, icon: .serviceSample, title: "ФССП", description: "Задолженность")
        }
    }
}
