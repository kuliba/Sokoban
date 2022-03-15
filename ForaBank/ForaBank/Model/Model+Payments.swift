//
//  ModelAction+Payments.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

//MARK: - Actions

extension ModelAction {
    
    enum Payment {
        
        typealias Category = Payments.Category
        typealias Service = Payments.Service
        typealias Operator = Payments.Operator
        typealias Parameter = Payments.Parameter
        typealias Operation = Payments.Operation
        
        enum Services {
            
            struct Request: Action {
                
                let category: Category
            }
            
            enum Response: Action {
                
                case select(Payments.ParameterSelectService)
                case selected(Service)
                case failed(Error)
            }
        }
        
        // begin payment process
        enum Begin {
            
            struct Request: Action {
                
                let source: Source

                enum Source {
                    
                    case service(Service)
                    case templateId(PaymentTemplateData.ID)
                }
            }

            struct Response: Action {
                
                let result: Result<Operation, Error>
            }
        }
        
        // continue payment process
        enum Continue {
     
            struct Request: Action {
                
                let operation: Operation
            }
            
            struct Response: Action {

                let result: Result
                
                enum Result {
                    
                    case step(Operation)
                    case confirm(Operation)
                    case fail(Error)
                }
            }
        }

        // complete payment
        enum Complete {
            
            struct Request: Action {
                
                let operation: Operation
            }
            
            struct Response: Action {
                
                let result: Result<SuccessData, Error>
                
                struct SuccessData {
                    
                    //TODO: success screen data
                }
            }
        }
    }
}

//MARK: - Handlers

extension Model {
    
    typealias Category = Payments.Category
    typealias Service = Payments.Service
    typealias Operator = Payments.Operator
    typealias Parameter = Payments.Parameter
    typealias Operation = Payments.Operation
    
    //MARK: - Handlers
    
    func handlePaymentsServicesRequest(_ payload: ModelAction.Payment.Services.Request) {
        
        if payload.category.services.count > 1 {
            
            let selectServiceParameter = Payments.ParameterSelectService(category: payload.category, options: payload.category.services.map { selectServiceParameterOption(for: $0)})
            
            action.send(ModelAction.Payment.Services.Response.select(selectServiceParameter))
            
        } else if let service = payload.category.services.first {
            
            action.send(ModelAction.Payment.Services.Response.selected(service))
            
        } else {
            
            action.send(ModelAction.Payment.Services.Response.failed(Payments.Operation.Error.unableSelectServiceForCategory(payload.category)))
        }
    }
    
    func handlePaymentsBeginRequest(_ payload: ModelAction.Payment.Begin.Request) {
        
        switch payload.source {
        case .service(let service):
            
            operation(for: service) { result in
                switch result {
                case .success(let operation):
                    self.action.send(ModelAction.Payment.Begin.Response(result: .success(operation)))
                    
                case .failure(let error):
                    self.action.send(ModelAction.Payment.Begin.Response(result: .failure(error)))
                }
            }
            
        case .templateId(let templateId):
            
            operation(for: templateId) { result in
                
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
        
        print("Payments: continue request")
        
        let operation = payload.operation
     
        parameters(for: operation.service, parameters: operation.parameters, history: operation.history) { result in

            switch result {
            case .success(let parameters):
                
                var historyUpdated = operation.history
                let historyValues = Operation.history(for: parameters)
                historyUpdated.append(historyValues)
                
                let continueOperation = Operation(service: operation.service, parameters: parameters, history: historyUpdated)

                if parameters.filter({ $0 is Payments.ParameterFinal }).count > 0 {
                    
                    self.action.send(ModelAction.Payment.Continue.Response(result: .confirm(continueOperation)))
                    
                } else {
                    
                    self.action.send(ModelAction.Payment.Continue.Response(result: .step(continueOperation)))
                }

            case .failure(let error):
                self.action.send(ModelAction.Payment.Continue.Response(result: .fail(error)))
            }
        }
    }
    
    func handlePaymentsCompleteRequest(_ payload: ModelAction.Payment.Complete.Request) {
        
        //TODO: make transfer
        self.action.send(ModelAction.Payment.Complete.Response(result: .success(.init())))
    }
    
    //MARK: - Operation
    
    func operation(for service: Service, completion: @escaping (Result<Operation, Error>) -> Void) {
        
        parameters(for: service, parameters: [], history: []) { result in
            
            switch result {
            case .success(let parameters):

                // selected operator required
                guard parameters.contains(where: { $0.parameter.id == Parameter.Identifier.operator.rawValue}) else {
                    completion(.failure(Payments.Operation.Error.operatorNotSelectedForService(service)))
                    return
                }
                
                let historyValues = Operation.history(for: parameters)
                let operation = Operation(service: service, parameters: parameters, history: [historyValues])
                completion(.success(operation))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func operation(for tempaleId: PaymentTemplateData.ID, completion: @escaping (Result<Operation, Error>) -> Void) {
        
        completion(.failure(Payments.Error.unsupported))
        
        //TODO: implementation required
        // - find template with id
        // - extract from template data:
        //      - payment service
        //      - create operation
    }
    
    //MARK: - Parameters
    
    func parameters(for service: Service, parameters: [ParameterRepresentable], history: [[Parameter]] , completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        let step = history.count
        
        print("Payments: step \(step)")
        
        switch service {
        case .fns:
            parametersFNS(parameters, step, completion)
            
        case .fms:
            parametersFMS(parameters, step, completion)
            
        case .fssp:
            parametersFSSP(parameters, step, completion)
        }
    }
    
    func selectServiceParameterOption(for service: Service) -> Payments.ParameterSelectService.Option {
        
        switch service {
        case .fns:
            return .init(service: service, title: service.name, description: "Налоги", icon: .serviceFNS)

        case .fms:
            return .init(service: service, title: service.name, description: "Госпошлины", icon: .serviceFMS)
            
        case .fssp:
            return .init(service: service, title: service.name, description: "Задолженность", icon: .serviceFSSP)
        }
    }
}
