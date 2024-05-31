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
        
        let operatorParameterId = Payments.Parameter.Identifier.operator.rawValue
        guard let operatorParameterValue = parameters.first(where: { $0.parameter.id ==  operatorParameterId})?.value else {
            
            throw Payments.Error.missingParameter(operatorParameterId)
        }
        
        return operatorParameterValue
    }
    
    func paymentsTransferPayer(_ parameters: [PaymentsParameterRepresentable]) throws -> TransferData.Payer {
        
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        guard let productParameter = parameters.first(where: { $0.parameter.id == productParameterId}) as? Payments.ParameterProduct,
              let productId = productParameter.productId,
              let productType = productType(for: productId) else {
            
            throw Payments.Error.missingParameter(productParameterId)
        }
        
        switch productType {
        case .card:
            return .init(inn: nil, accountId: nil, accountNumber: nil, cardId: productId, cardNumber: nil, phoneNumber: nil)
        case .account:
            return .init(inn: nil, accountId: productId, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        default:
            throw Payments.Error.unexpectedProductType(productType)
        }
    }
    
    func paymentsTransferAmount(_ parameters: [PaymentsParameterRepresentable]) throws -> Double? {
        
        let amountParameterId = Payments.Parameter.Identifier.amount.rawValue
        guard let amountParameter = parameters.first(where: { $0.parameter.id == amountParameterId }) as? Payments.ParameterAmount else {
            
            return nil
        }
        
        return amountParameter.amount
    }
    
    func paymentsTransferCurrency(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        guard let productParameter = parameters.first(where: { $0.parameter.id ==  productParameterId}) as? Payments.ParameterProduct,
              let productId = productParameter.productId,
              let product = product(productId: productId) else {
            
            throw Payments.Error.missingParameter(productParameterId)
        }
        
        return product.currency
    }
    
    func paymentsTransferComment(_ parameters: [PaymentsParameterRepresentable]) throws -> String? {
        
        return nil
    }
}

//MARK: - Step

extension Model {
    
    func paymentsTransferStepParameters(_ operation: Payments.Operation, response: TransferResponseData) throws -> [PaymentsParameterRepresentable] {
        
        return []
    }
    
    func paymentsTransferStepVisible(_ operation: Payments.Operation, nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], response: TransferResponseData) throws -> [Payments.Parameter.ID] {
        
        var result = [Payments.Parameter.ID]()
        
        let nexStepParametersIds = nextStepParameters.map{ $0.id }
        result.append(contentsOf: nexStepParametersIds)

        return result.filter({ $0 != Payments.Parameter.Identifier.sfpAntifraud.rawValue })
    }
    
    func paymentsTransferStepStage(_ operation: Payments.Operation, response: TransferResponseData) throws -> Payments.Operation.Stage {
        
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
    
    func paymentsTransferStepRequired(_ operation: Payments.Operation, visible: [Payments.Parameter.ID], nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], restrictedParameters: [Payments.Parameter.ID]) throws -> [Payments.Parameter.ID] {
        
        nextStepParameters
            .filter {
                visible.contains($0.id)
                && !restrictedParameters.contains($0.id)
            }
            .map(\.id)
    }
}

extension Model {
    
    func makeSections(
        flag: UpdateInfoStatusFeatureFlag
    ) -> [PaymentsTransfersSectionViewModel] {
        
        var sections = [
            PTSectionLatestPaymentsView.ViewModel(model: self),
            PTSectionTransfersView.ViewModel(),
            PTSectionPaymentsView.ViewModel()

        ]
        if flag.isActive,
            !self.updateInfo.value.areProductsUpdated {
                sections.insert(UpdateInfoPTViewModel(), at: 0)
        }
        return sections
    }
}
