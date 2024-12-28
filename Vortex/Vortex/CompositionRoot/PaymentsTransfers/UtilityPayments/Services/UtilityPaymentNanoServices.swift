//
//  UtilityPaymentNanoServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentDomain
import VortexTools
import OperatorsListComponents
import RemoteServices

struct UtilityPaymentNanoServices {
    
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    let getAllLatestPayments: GetAllLatestPayments
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    let getOperatorsListByParam: GetOperatorsListByParam
    
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    let getServicesFor: GetServicesFor
    
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST /rest/transfer/createAnywayTransfer?isNewPayment=true
    let startAnywayPayment: StartAnywayPayment
}

extension UtilityPaymentNanoServices {
    
    // MARK: - GetAllLatestPayments
    
    typealias GetAllLatestPaymentsCompletion = ([LastPayment]) -> Void
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    typealias GetAllLatestPayments = (@escaping GetAllLatestPaymentsCompletion) -> Void
    
    // MARK: - GetOperatorsListByParam
    
    typealias GetOperatorsListByParamCompletion = ([Operator]) -> Void
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    typealias GetOperatorsListByParam = (@escaping GetOperatorsListByParamCompletion) -> Void
    
    // MARK: - GetServicesFor
    
    struct GetServicesForError: Error, Equatable {}
    
    typealias GetServicesForResult = Result<[Service], GetServicesForError>
    typealias GetServicesForCompletion = (GetServicesForResult) -> Void
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    typealias GetServicesFor = (Operator, @escaping GetServicesForCompletion) -> Void
    
    // MARK: - StartAnywayPayment
    
    typealias InitiateAnywayPaymentDomain = Vortex.InitiateAnywayPaymentDomain<LastPayment, Operator, Service, StartPaymentResponse>
    typealias StartPaymentResponse = RemoteServices.ResponseMapper.CreateAnywayTransferResponse
    
    enum StartAnywayPaymentPayload: Equatable {
        
        case lastPayment(LastPayment)
        case service(Service, for: Operator)
    }
    
    typealias StartAnywayPaymentResult = InitiateAnywayPaymentDomain.Result
    typealias StartAnywayPaymentSuccess = InitiateAnywayPaymentDomain.Success
    typealias StartAnywayPaymentFailure = InitiateAnywayPaymentDomain.Failure
    
    typealias StartAnywayPaymentCompletion = (StartAnywayPaymentResult) -> Void
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST
    /// /rest/transfer/createAnywayTransfer?isNewPayment=true
    typealias StartAnywayPayment = (StartAnywayPaymentPayload, @escaping StartAnywayPaymentCompletion) -> Void
    
    // MARK: - Domain
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentProvider
    typealias Service = UtilityService
}
