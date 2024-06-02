//
//  UtilityPaymentNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import AnywayPaymentDomain
import ForaTools
import OperatorsListComponents
import RemoteServices

struct UtilityPaymentNanoServices<LastPayment, Operator, UtilityService> {
    
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
    
    let makeAnywayPaymentOutline: MakeAnywayPaymentOutline
}

extension UtilityPaymentNanoServices {
    
    typealias GetAllLatestPaymentsCompletion = ([LastPayment]) -> Void
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    typealias GetAllLatestPayments = (@escaping GetAllLatestPaymentsCompletion) -> Void
    
    typealias GetOperatorsListByParamCompletion = ([Operator]) -> Void
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    typealias GetOperatorsListByParam = (@escaping GetOperatorsListByParamCompletion) -> Void
    
    struct GetServicesForError: Error, Equatable {}
    typealias GetServicesForResult = Result<[UtilityService], GetServicesForError>
    typealias GetServicesForCompletion = (GetServicesForResult) -> Void
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    typealias GetServicesFor = (Operator, @escaping GetServicesForCompletion) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias PrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, UtilityService>
    
    enum StartAnywayPaymentPayload {
        
        case lastPayment(LastPayment)
        case service(UtilityService, for: Operator)
    }
    
    typealias StartAnywayPaymentResult = Result<StartAnywayPaymentSuccess, StartAnywayPaymentFailure>
    
    enum StartAnywayPaymentSuccess {
        
        case services(MultiElementArray<UtilityService>, for: Operator)
        case startPayment(StartPaymentResponse)
        
        typealias StartPaymentResponse = RemoteServices.ResponseMapper.CreateAnywayTransferResponse
    }
    
    enum StartAnywayPaymentFailure: Error {
        
        case operatorFailure(Operator)
        case serviceFailure(ServiceFailure)
        
#warning("extract…")
        enum ServiceFailure: Error, Hashable {
            
            case connectivityError
            case serverError(String)
        }
    }
    
    typealias StartAnywayPaymentCompletion = (StartAnywayPaymentResult) -> Void
    /// `e`
    /// Начало выполнения перевода - 1шаг, передаем `isNewPayment=true`
    /// POST
    /// /rest/transfer/createAnywayTransfer?isNewPayment=true
    typealias StartAnywayPayment = (StartAnywayPaymentPayload, @escaping StartAnywayPaymentCompletion) -> Void
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    typealias MakeAnywayPaymentOutline = (LastPayment?) -> AnywayPaymentOutline
}

extension UtilityPaymentNanoServices.StartAnywayPaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
