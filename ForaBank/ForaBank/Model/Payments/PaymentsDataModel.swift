//
//  PaymentsDataModel.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

enum Payments {

    enum Category: String {
        
        case taxes = "iFora||1331001"
        
        var services: [Service] {
            
            switch self {
            case .taxes: return [.fns, .fms, .fssp]
            }
        }
        
        var name: String {
            
            switch self {
            case .taxes: return "Налоги и услуги"
            }
        }
    }
    
    enum Service: String {
        
        case fms
        case fns
        case fssp
    }
    
    enum Operator : String {
        
        case fssp       = "iFora||5429"
        case fms        = "iFora||6887"
        case fns        = "iFora||6273"
        case fnsUin     = "iFora||7069"
    }
    
    struct Parameter: Equatable, CustomDebugStringConvertible {
        
        typealias ID = String
        typealias Value = String?
        
        let id: ID
        let value: Value
        
        var debugDescription: String { "id: \(id), value: \(value != nil ? value! : "empty")" }
    }
    
    struct Operation {
        
        let service: Service
        let parameters: [ParameterRepresentable]
        let history: [[Parameter]]
    }
    
    struct Success {

        let status: Status
        let amount: Double
        let currency: Currency
        let icon: ImageData?
        let operationDetailId: Int
        
        internal init(status: Payments.Success.Status, amount: Double, currency: Currency, icon: ImageData?, operationDetailId: Int) {
            
            self.status = status
            self.amount = amount
            self.currency = currency
            self.icon = icon
            self.operationDetailId = operationDetailId
        }

        init(with response: TransferResponseBaseData, operation: Payments.Operation) throws {
            
            self.status = Status(with: response.documentStatus)
            self.amount = try Self.amount(with: response, operation: operation)
            self.currency = try Self.currency(with: response, operation: operation)
            self.icon = nil
            self.operationDetailId = response.paymentOperationDetailId
        }
        
        static func amount(with response: TransferResponseBaseData, operation: Payments.Operation) throws -> Double {
        
            if let anywayTransferResponse = response as? TransferAnywayResponseData,
                let amount = anywayTransferResponse.amount {
                
                return amount
                
            } else if let parameter = operation.parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue }) as? Payments.ParameterAmount {
                
                return parameter.amount
                
            } else {
                
                throw Payments.Error.missingAmountParameter
            }
        }
        
        static func currency(with response: TransferResponseBaseData, operation: Payments.Operation) throws -> Currency {
        
            if let anywayTransferResponse = response as? TransferAnywayResponseData,
                let currencyValue = anywayTransferResponse.currencyAmount {
                
                return currencyValue
                
            } else if let parameter = operation.parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue }) as? Payments.ParameterAmount {
                
                return parameter.currency
                
            } else {
                
                throw Payments.Error.missingCurrency
            }
        }
        
        enum Status {
            
            case complete
            case inProgress
            case rejected
            
            var description: String {
                
                switch self {
                case .complete: return "Оплата прошла успешно"
                case .inProgress: return "Операция выполняется"
                case .rejected: return "Отказ"
                }
            }
            
            init(with documentStatus: TransferResponseBaseData.DocumentStatus?) {
                
                //FIXME: TransferResponseBaseData.DocumentStatus must be not optional
                guard let documentStatus = documentStatus else {
                    
                    self = .inProgress
                    return
                }
                
                switch documentStatus {
                case .complete: self = .complete
                case .inProgress: self = .inProgress
                case .rejected: self = .rejected
                //FIXME: status for unknown document status required
                default: self = .inProgress
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        
        case unableLoadFMSCategoryOptions
        case unableLoadFTSCategoryOptions
        case unableLoadFSSPDocumentOptions
        case unableCreateOperationForService(Service)
        case unexpectedOperatorValue
        case missingOperatorParameter
        case missingParameter
        case missingPayer
        case missingCurrency
        case missingCodeParameter
        case missingAmountParameter
        case missingAnywayTransferAdditional
        case failedObtainProductId
        case failedTransferWithEmptyDataResponse
        case failedTransfer(status: ServerStatusCode, message: String?)
        case failedMakeTransferWithEmptyDataResponse
        case failedMakeTransfer(status: ServerStatusCode, message: String?)
        case clientInfoEmptyResponse
        case anywayTransferFinalStepExpected
        case notAuthorized
        case unsupported
    }
}

protocol ParameterRepresentable {

    var parameter: Payments.Parameter { get }
    
    /// the paramreter can be edited
    var isEditable: Bool { get }
    
    /// the parameter can be collapsed
    var isCollapsable: Bool { get }
    
    /// the parameter can be hidden
    var isHidden: Bool { get }
    
    /// the parameter affects the history and the operation is reset to the step at which the value was originally set
    var affectsHistory: Bool { get }
    
    /// the paramreter after value update requests auto continue operation
    var isAutoContinue: Bool { get }
    
    /// transaction step on witch parameter must be processed
    var processStep: Int? { get }
    
    /// the parameter affects other parameters
    var affectsParameters: Bool { get }
    
    func updated(value: String?) -> ParameterRepresentable
    func updated(isEditable: Bool) -> ParameterRepresentable
    func updated(isHidden: Bool) -> ParameterRepresentable
}

extension ParameterRepresentable {

    var isEditable: Bool { false }
    var isCollapsable: Bool { false }
    var isHidden: Bool { false }
    var affectsHistory: Bool { false }
    var isAutoContinue: Bool { false }
    var processStep: Int? { nil }
    var affectsParameters: Bool { false }
    
    func updated(value: String?) -> ParameterRepresentable { self }
    func updated(isEditable: Bool) -> ParameterRepresentable { self }
    func updated(isHidden: Bool) -> ParameterRepresentable { self }
}
