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
    
    enum ParameterOnChangeAction {
        
        case none
        case autoContinue
        case updateParameters
    }

    enum ParameterProcessType {
        
        case none
        case initial
        case step(Int)
    }
    
    struct Operation {
        
        let service: Service
        let parameters: [PaymentsParameterRepresentable]
        let processed: [Parameter]
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

protocol PaymentsParameterRepresentable {

    var parameter: Payments.Parameter { get }
    
    /// the paramreter can be edited
    var isEditable: Bool { get }
    
    /// the parameter can be collapsed
    var isCollapsable: Bool { get }
    
    /// the parameter can be hidden
    var isHidden: Bool { get }
    
    /// action performed in case of parameter value change
    var onChange: Payments.ParameterOnChangeAction { get }

    /// type of processing the parameter during the execution of the transaction
    var process: Payments.ParameterProcessType { get }
    
    func updated(value: String?) -> PaymentsParameterRepresentable
    func updated(isEditable: Bool) -> PaymentsParameterRepresentable
    func updated(isHidden: Bool) -> PaymentsParameterRepresentable
}

extension PaymentsParameterRepresentable {

    var isEditable: Bool { false }
    var isCollapsable: Bool { false }
    var isHidden: Bool { false }
    var onChange: Payments.ParameterOnChangeAction { .none }
    var process: Payments.ParameterProcessType { .none }
    
    func updated(value: String?) -> PaymentsParameterRepresentable { self }
    func updated(isEditable: Bool) -> PaymentsParameterRepresentable { self }
    func updated(isHidden: Bool) -> PaymentsParameterRepresentable { self }
}
