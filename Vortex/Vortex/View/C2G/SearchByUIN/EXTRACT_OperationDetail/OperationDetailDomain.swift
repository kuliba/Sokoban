//
//  OperationDetailDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import StateMachines
import RxViewModel

enum OperationDetailDomain {}

extension OperationDetailDomain {
    
    typealias Model = RxViewModel<State, Event, Effect>
    
    typealias Reducer = StateMachines.LoadReducer<State.Details, Error>
    typealias EffectHandler = StateMachines.LoadEffectHandler<State.Details, Error>
    
    typealias Event = StateMachines.LoadEvent<State.Details, Error>
    typealias Effect = StateMachines.LoadEffect
    
    struct State {
        
        var details: DetailsState
        let response: EnhancedResponse
        
        typealias DetailsState = StateMachines.LoadState<Details, Error>
        
        struct Details: Equatable {
            
            let dateForDetail: String?   // Дата и время операции (МСК) - dateForDetail
            let realPayerFIO: String?    // Информация о плательщике - "realPayerFIO"
            let payeeFullName: String?   // Получатель - payeeFullName
            let supplierBillID: String?  // Номер документа (УИН) - "supplierBillID"
            let comment: String?         // Назначение платежа - "comment"
            let realPayerINN: String?    // ИНН плательщика - “realPayerINN”
            let realPayerKPP: String?    // КПП плательщика - “realPayerKPP"
            let dateN: String?           // Дата начисления - "dateN"
            let paymentTerm: String?     // Срок оплаты - "paymentTerm"
            let legalAct: String?        // Информация о НПА - "legalAct"
            let transAmm: String?        // Сумма начисления - "transAmm"
            let discount: String?        // Скидка - "discountFixedValue"/ "discountSizeValue"/ "multiplierSizeValue"
            // !!! map to enum - has different formatting -
            /* Скидки:          "discountFixedValue": 500 - Сумма скидки от полной суммы начисления, всегда в рублях         "discountSizeValue": 10- Процент скидки от суммы начисления         "multiplierSizeValue": 0,5 -Коэффициент, понижающий размер начисления 
             */
            let discountExpiry: String?  // Срок действия скидки - "discountExpiry"
            let formattedAmount: String? // Сумма платежа - payerAmount+ payerCurrency
            let upno: String?            // УПНО - "UPNO"
            let transferNumber: String?  // Идентификатор операции СБП - "transferNumber"
        }
        
        struct EnhancedResponse: Equatable {
            
            let formattedAmount: String?
            let formattedDate: String?
            let merchantName: String?
            let message: String?
            let paymentOperationDetailID: Int
            let product: ProductData // too much
            let purpose: String?
            let status: Status
            let uin: String
            
            enum Status {
                
                case completed, inflight, rejected
            }
        }
    }
}
