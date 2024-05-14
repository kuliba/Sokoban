//
//  UtilityPaymentNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import OperatorsListComponents

struct UtilityPaymentNanoServices<LastPayment, Operator>
where Operator: Identifiable {
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    let getOperatorsListByParam: GetOperatorsListByParam
    
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    let getAllLatestPayments: GetAllLatestPayments
}

extension UtilityPaymentNanoServices {
    
    typealias PageSize = Int
    typealias GetOperatorsListByParamCompletion = ([Operator]) -> Void
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    typealias GetOperatorsListByParam = (PageSize, @escaping GetOperatorsListByParamCompletion) -> Void
    
    typealias GetAllLatestPaymentsCompletion = ([LastPayment]) -> Void
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    typealias GetAllLatestPayments = (@escaping GetAllLatestPaymentsCompletion) -> Void
}
