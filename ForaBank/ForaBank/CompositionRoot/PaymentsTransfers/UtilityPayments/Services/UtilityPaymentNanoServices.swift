//
//  UtilityPaymentNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import OperatorsListComponents

struct UtilityPaymentNanoServices<LastPayment, Operator> {
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    let getOperatorsListByParam: GetOperatorsListByParam
    
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    let getAllLatestPayments: GetAllLatestPayments
    
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST /rest/transfer/createAnywayTransfer?isNewPayment=true
    let startAnywayPayment: StartAnywayPayment
    
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    let getServicesFor: GetServicesFor
}

extension UtilityPaymentNanoServices {
    
    typealias GetOperatorsListByParamCompletion = ([Operator]) -> Void
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    typealias GetOperatorsListByParam = (@escaping GetOperatorsListByParamCompletion) -> Void
    
    typealias GetAllLatestPaymentsCompletion = ([LastPayment]) -> Void
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    typealias GetAllLatestPayments = (@escaping GetAllLatestPaymentsCompletion) -> Void
    
    enum StartAnywayPaymentPayload {
        
        case lastPayment(LastPayment)
        case service(UtilityService)
    }
    typealias StartAnywayPaymentResult = UtilityPrepaymentFlowEvent.StartPaymentResult
    typealias StartAnywayPaymentCompletion = (StartAnywayPaymentResult) -> Void
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST
    /// /rest/transfer/createAnywayTransfer?isNewPayment=true
    typealias StartAnywayPayment = (StartAnywayPaymentPayload, @escaping StartAnywayPaymentCompletion) -> Void
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    struct GetServicesForError: Error, Equatable {}
    typealias GetServicesForResult = Result<[UtilityService], GetServicesForError>
    typealias GetServicesForCompletion = (GetServicesForResult) -> Void
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    typealias GetServicesFor = (Operator, @escaping GetServicesForCompletion) -> Void
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias UtilityPrepaymentFlowEvent = UtilityFlowEvent.UtilityPrepaymentFlowEvent
}

extension UtilityPaymentNanoServices.StartAnywayPaymentPayload: Equatable where LastPayment: Equatable {}
