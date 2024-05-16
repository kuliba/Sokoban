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
    
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST
    /// /rest/transfer/createAnywayTransfer?isNewPayment=true
    typealias StartAnywayPayment = PrepaymentFlowEffectHandler.StartPayment
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}
