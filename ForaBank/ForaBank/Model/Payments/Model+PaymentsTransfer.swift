//
//  Model+PaymentsTransfer.swift
//  ForaBank
//
//  Created by Max Gribov on 21.10.2022.
//

import Foundation

//MARK: - Request

extension Model {
    
    func paymentsTransferProcess(parameters: [PaymentsParameterRepresentable], process: [Payments.Parameter], isNewPayment: Bool) async throws -> TransferAnywayResponseData {
        
        //TODO: implementation required
        throw Payments.Error.unsupported
    }
}

//MARK: Request Parameters

extension Model {
    
    func paymentsTransferPuref(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        guard let operatorParameterValue = parameters.first(where: { $0.parameter.id ==  Payments.Parameter.Identifier.operator.rawValue})?.value else {
            
            throw Payments.Error.missingOperatorParameter
        }
        
        return operatorParameterValue
    }
    
    func paymentsTransferPayer(_ parameters: [PaymentsParameterRepresentable]) throws -> TransferData.Payer {
        
        guard let productParameter = parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.product.rawValue }) as? Payments.ParameterProduct,
              let productId = productParameter.productId,
              let productType = productType(for: productId) else {
            
            throw Payments.Error.missingProduct
        }
        
        switch productType {
        case .card:
            return .init(inn: nil, accountId: nil, accountNumber: nil, cardId: productId, cardNumber: nil, phoneNumber: nil)
        case .account:
            return .init(inn: nil, accountId: productId, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        default:
            throw Payments.Error.unexpectedProductType
        }
    }
    
    func paymentsTransferAmount(_ parameters: [PaymentsParameterRepresentable]) throws -> Double {
        
        guard let amountParameter = parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue}) as? Payments.ParameterAmount else {
            
            throw Payments.Error.missingAmount
        }
        
        return amountParameter.amount
    }
    
    func paymentsTransferCurrency(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        guard let productParameter = parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.product.rawValue }) as? Payments.ParameterProduct,
              let productId = productParameter.productId,
              let product = product(productId: productId) else {
            
            throw Payments.Error.missingProduct
        }
        
        return product.currency
    }
    
    func paymentsTransferComment(_ parameters: [PaymentsParameterRepresentable]) throws -> String? {
        
        return nil
    }
}

//MARK: - Step

extension Model {
    
    func paymentsTransferStepParameters(service: Payments.Service, response: TransferResponseData) throws -> [PaymentsParameterRepresentable] {
        
        return []
    }
    
    func paymentsTransferStepVisible(service: Payments.Service, nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], response: TransferResponseData) throws -> [Payments.Parameter.ID] {
        
        var result = [Payments.Parameter.ID]()
        
        let nexStepParametersIds = nextStepParameters.map{ $0.id }
        result.append(contentsOf: nexStepParametersIds)

        return result
    }
    
    func paymentsTransferStepStage(service: Payments.Service, operation: Payments.Operation, response: TransferResponseData) throws -> Payments.Operation.Stage {
        
        if response.needOTP == true {
            
            return .remote(.confirm)
            
        } else {
            
            if response.needMake == true {
                
                return .remote(.complete)
                
            } else {
                
                let operationStepsStages = operation.steps.map{ $0.back.stage }
                if operationStepsStages.count > 0 {
                    
                    return .remote(.next)
                    
                } else {
                    
                    return .remote(.start)
                }
            }
        }
    }
    
    func paymentsTransferStepTerms(service: Payments.Service, visible: [Payments.Parameter.ID], nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable]) throws -> [Payments.Operation.Step.Term] {
        
        var result = [Payments.Operation.Step.Term]()
        
        let parameters = operationParameters + nextStepParameters
        
        for parameterId in visible {
            
            guard let parameter = parameters.first(where: { $0.id == parameterId }) else {
                throw Payments.Error.missingParameter
            }
            
            switch parameter {
            case _ as Payments.ParameterSelect:
                result.append(.init(parameterId: parameterId, impact: .rollback))
                
            case _ as Payments.ParameterSelectSimple:
                result.append(.init(parameterId: parameterId, impact: .rollback))
                
            case _ as Payments.ParameterSelectSwitch:
                result.append(.init(parameterId: parameterId, impact: .rollback))
                
            case _ as Payments.ParameterInput:
                result.append(.init(parameterId: parameterId, impact: .restart))
                
            case _ as Payments.ParameterName:
                result.append(.init(parameterId: parameterId, impact: .restart))
                
            case _ as Payments.ParameterProduct:
                result.append(.init(parameterId: parameterId, impact: .restart))
                
            case _ as Payments.ParameterAmount:
                result.append(.init(parameterId: parameterId, impact: .restart))
            
            default:
                continue
                
            }
        }
        
        return result
    }
}
