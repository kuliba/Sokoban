//
//  Payments.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

//MARK: - General

enum Payments {

    enum Category: String, CaseIterable {
        
        case fast  = "ru.forabank.sense.payments.category.fast"
        case taxes = "iFora||1331001"
        
        var services: [Service] {
            
            switch self {
            case .fast: return [.sfp, .direct]
            case .taxes: return [.fns, .fms, .fssp]
            }
        }
        
        var name: String {
            
            switch self {
            case .fast: return "Быстрые платежи"
            case .taxes: return "Налоги и услуги"
            }
        }
        
        static func category(for service: Service) -> Category? {
            
            for category in Category.allCases {
                
                if category.services.contains(service) {
                    
                    return category
                }
            }
            
            return nil
        }
    }
    
    enum Service: String {
        
        case sfp
        case direct
        case fms
        case fns
        case fssp
    }
    
    enum Operator : String {
        
        case sfp        = "iFora||TransferC2CSTEP"
        case direct     = "REQUIRED!!!!!"
        case fssp       = "iFora||5429"
        case fms        = "iFora||6887"
        case fns        = "iFora||6273"
        case fnsUin     = "iFora||7069"
    }
}

//MARK: - Parameter

extension Payments {
    
    struct Parameter: Equatable, Hashable, CustomDebugStringConvertible {
        
        typealias ID = String
        typealias Value = String?
        
        let id: ID
        let value: Value
        
        var debugDescription: String { "\(id)[\(value != nil ? value! : "empty")]" }
    }
}

extension Payments.Parameter {
    
    enum Placement: CaseIterable {
        
        case top
        case feed
        case spoiler
        case bottom
    }
    
    enum View {
        
        case select
        case selectSwitch
        case input
        case info
    }
}

//MARK: - Operation

extension Payments {
    
    struct Operation {

        let service: Service
        let source: Source?
        let steps: [Step]
        
        init(service: Service, source: Source?, steps: [Step]) {
            
            self.service = service
            self.source = source
            self.steps = steps
        }
        
        init(service: Service) {
            
            self.init(service: service, source: nil, steps: [])
        }
        
        init(service: Service, source: Source) {
            
            self.init(service: service, source: source, steps: [])
        }
    }
}

extension Payments.Operation {
    
    /// Source of operation
    enum Source: CustomDebugStringConvertible {
        
        /// operation started from template
        case template(PaymentTemplateData)
        
        /// operation started from latest operation
        case latestPayment(LatestPaymentData)
        
        case qr
        
        case sfp(phone: String, bank: BankData)
        
        case direct(phone: String, bank: BankData, country: CountryData)
        
        case abroad(phone: String, country: CountryData)
        
        case mock(Payments.Mock)
        
        var debugDescription: String {
            
            switch self {
            case let .template(template): return "template: \(template.id)"
            case let .latestPayment(latestPayment): return "latest payment: \(latestPayment.id)"
            case .qr: return "qr"
            case let .sfp(phone: phone, bank: bank): return "sfp: \(phone), bankId: \(bank.id)"
            case let .direct(phone: phone, bank: bank, country: country): return "direct: \(phone), bankId: \(bank.id), countryId: \(country.id)"
            case let .abroad(phone: phone, country: country): return "abroad: \(phone), countryId: \(country.id)"
            case let .mock(mock): return "mock service: \(mock.service.rawValue)"
            }
        }
    }
    
    /// Operation step
    struct Step {
        
        let parameters: [PaymentsParameterRepresentable]
        let front: Front
        let back: Back
        
        struct Front: Equatable {
            
            /// Parameters visible in UI
            let visible: [Parameter.ID]
            
            /// Is user complete updatding all parameters for this step
            let isCompleted: Bool
        }
        
        struct Back: Equatable {
            
            let stage: Stage
            
            /// Parameters requred to process
            let required: [Payments.Parameter.ID]
            
            /// Parameters processed
            let processed: [Payments.Parameter]?
        }

        
        enum Status: Equatable {
            
            /// updating parameters on front side
            case editing
            
            /// pending parameters to back side
            case pending(parameters: [Parameter], stage: Stage)
            
            /// paramaters updated on front side and processed on back side if required
            case complete
            
            /// parameters changed after procrssing
            case invalidated
        }
        
        struct ProcessedData {
            
            let current: Payments.Parameter
            let processed: Payments.Parameter
        }
    }
    
    enum Stage: Equatable, CustomDebugStringConvertible {
        
        case local
        case remote(Remote)

        enum Remote: String {
            
            case start
            case next
            case confirm
            case complete
        }
        
        var debugDescription: String {
            
            switch self {
            case .local: return "local"
            case let .remote(remote): return "remote: \(remote)"
            }
        }
    }
    
    enum TransferType {
        
        case anyway
        case sfp
        case direct
    }
    
    enum Action: Equatable {
        
        /// step required
        case step(index: Int)
        
        /// required update parameters values in ui by user
        case frontUpdate
        
        /// operation confirm required in ui by user
        case frontConfirm
        
        /// process parameters on server
        case backProcess(parameters: [Parameter], stepIndex: Int, stage: Stage)
        
        /// rollback operation to step
        case rollback(stepIndex: Int)
    }
}

//MARK: - Success

extension Payments {
    
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
        
            //FIXME: - refactor
            return 0
            /*
            if let anywayTransferResponse = response as? TransferAnywayResponseData,
                let amount = anywayTransferResponse.amount {
                
                return amount
                
            } else if let parameter = operation.parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue }) as? Payments.ParameterAmount {
                
                return parameter.amount
                
            } else {
                
                throw Payments.Error.missingAmountParameter
            }
             */
        }
        
        static func currency(with response: TransferResponseBaseData, operation: Payments.Operation) throws -> Currency {
        
            //FIXME: - refactor
            return .eur
            /*
            if let anywayTransferResponse = response as? TransferAnywayResponseData,
                let currencyValue = anywayTransferResponse.currencyAmount {
                
                return currencyValue
                
            } else if let parameter = operation.parameters.first(where: { $0.parameter.id == Payments.Parameter.Identifier.amount.rawValue }) as? Payments.ParameterAmount {
                
                return parameter.currency
                
            } else {
                
                throw Payments.Error.missingCurrency
            }
             */
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
}

//MARK: - Process

extension Payments {
    
    enum ProcessResult: CustomDebugStringConvertible {
        
        case step(Operation)
        case confirm(Operation)
        case complete(Payments.Success)
        
        var debugDescription: String {
            
            switch self {
            case .step: return "step"
            case .confirm: return "confirm"
            case .complete: return "complete"
            }
        }
    }
}

//MARK: - Mock

extension Payments {
    
    struct Mock {
        
        let service: Payments.Service
        let parameters: [Payments.Parameter]
    }
}

//MARK: - Error

extension Payments {
    
    enum Error: LocalizedError {
        
        case unableCreateOperationForService(Service)
        case unableCreateRepresentable(Payments.Parameter.ID)
        case unexpectedProductType(ProductType)
        case unexpectedProcessResult(Payments.ProcessResult)
        
        case missingParameter(Payments.Parameter.ID)
        case missingOptions(ParameterData)
        case missingValueForParameter(Payments.Parameter.ID)
        case missingValue(ParameterData)

        case notAuthorized
        case unsupported
        
        var errorDescription: String? {
            
            switch self {
            case let .unableCreateOperationForService(service):
                return "Unable create operation for service: \(service)"
                
            case let .unableCreateRepresentable(parameterId):
                return "Unable create representable parameter for parameter id: \(parameterId)"
                
            case let .unexpectedProductType(productType):
                return "Unexpected product type: \(productType)"
                
            case let .unexpectedProcessResult(result):
                return "Unexpected operation processing result: \(result)"
                
            case let .missingParameter(parameterId):
                return "Missing parameter with id: \(parameterId)"
                
            case let .missingOptions(parameterData):
                return "Missing options in parameter data: \(parameterData)"
                
            case let .missingValue(parameterData):
                return "Missing value in parameter data: \(parameterData)"
            
            case let .missingValueForParameter(parameterId):
                return "Missing value for parameter: \(parameterId)"

            case .notAuthorized:
                return "Not authorized request attempt"
                
            case .unsupported:
                return "Unsupported"
            }
        }
    }
}
