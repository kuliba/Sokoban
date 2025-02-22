//
//  OperationDetailDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import C2GCore
import Foundation
import ProductSelectComponent
import RxViewModel
import StateMachines

enum OperationDetailDomain {}

extension OperationDetailDomain {
    
    typealias Model = RxViewModel<State, Event, Effect>
    
    // MARK: - Logic
    
    typealias Reducer = StateMachines.LoadReducer<ExtendedDetails, Error>
    typealias EffectHandler = StateMachines.LoadEffectHandler<ExtendedDetails, Error>
    
    // MARK: - (Rx)Domain
    
    struct State {
        
        let basicDetails: BasicDetails
        var extendedDetails: ExtendedDetailsState
        
        typealias ExtendedDetailsState = StateMachines.LoadState<ExtendedDetails, Error>
    }
    
    typealias Event = StateMachines.LoadEvent<ExtendedDetails, Error>
    typealias Effect = StateMachines.LoadEffect
    
    // MARK: - Digests
    
    typealias PaymentDigest = C2GCore.C2GPaymentDigest // TODO: decouple or leave as is
    
    struct StatementDigest: Equatable {
        
        let documentID: String // optional Int in statement but needed as String to call `getOperationDetail` API
        
        // from product statement v3: getAccountStatementForPeriod_V3 | getCardStatementForPeriod_V3
        let dateN: String?           // Дата начисления - "dateN"
        let discount: String?        // Скидка - "discountFixedValue"/ "discountSizeValue"/ "multiplierSizeValue"
        let discountExpiry: String?  // Срок действия скидки - "discountExpiry"
        let legalAct: String?        // Информация о НПА - "legalAct"
        let paymentTerm: String?     // Срок оплаты - "paymentTerm"
        let realPayerFIO: String?    // Информация о плательщике - "realPayerFIO"
        let realPayerINN: String?    // ИНН плательщика - “realPayerINN”
        let realPayerKPP: String?    // КПП плательщика - “realPayerKPP"
        let supplierBillID: String?  // Номер документа (УИН) - "supplierBillID"
        let transAmm: String?        // Сумма начисления - "transAmm"
        let upno: String?            // УПНО - "UPNO"
    }
    
    // MARK: - Details
    
    struct BasicDetails: Equatable {
        
        let product: Product
        let status: Status
        
        // from payment (on payment completion)
        let formattedAmount: String?
        let formattedDate: String?
        let merchantName: String?
        let message: String?
        let paymentOperationDetailID: Int
        let purpose: String?
        let uin: String
    }

    struct CoreDetails: Equatable {
        
        let product: Product
        let status: Status
    }
    
    struct ExtendedDetails: Equatable {
        
        let product: Product
        let status: Status
        
        let comment: String?         // Назначение платежа - "comment"
        let dateForDetail: String?   // Дата и время операции (МСК) - dateForDetail
        let dateN: String?           // Дата начисления - "dateN"
        let discount: String?        // Скидка - "discountFixedValue"/ "discountSizeValue"/ "multiplierSizeValue"
        let discountExpiry: String?  // Срок действия скидки - "discountExpiry"
        let formattedAmount: String? // Сумма платежа - payerAmount+ payerCurrency
        let legalAct: String?        // Информация о НПА - "legalAct"
        let payeeFullName: String?   // Получатель - payeeFullName
        let paymentTerm: String?     // Срок оплаты - "paymentTerm"
        let realPayerFIO: String?    // Информация о плательщике - "realPayerFIO"
        let realPayerINN: String?    // ИНН плательщика - “realPayerINN”
        let realPayerKPP: String?    // КПП плательщика - “realPayerKPP"
        let supplierBillID: String?  // Номер документа (УИН) - "supplierBillID"
        let transAmm: String?        // Сумма начисления - "transAmm"
        let transferNumber: String?  // Идентификатор операции СБП - "transferNumber"
        let upno: String?            // УПНО - "UPNO"
    }
    
    typealias Product = ProductSelect.Product // TODO: decouple or leave as is
    
    enum Status {
        
        case completed, inflight, rejected
    }
}

extension ProductStatementData {
    
    var digest: OperationDetailDomain.StatementDigest? {
        
        guard let documentId else { return nil }
        
        return .init(
            documentID: "\(documentId)",
            dateN: dateN,
            discount: discount,
            discountExpiry: discountExpiry,
            legalAct: legalAct,
            paymentTerm: paymentTerm,
            realPayerFIO: realPayerFIO,
            realPayerINN: realPayerINN,
            realPayerKPP: realPayerKPP,
            supplierBillID: supplierBillID,
            transAmm: transAmm,
            upno: upno
        )
    }
}
