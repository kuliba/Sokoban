//
//  RootViewModelFactory+loadServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.12.2024.
//

import RemoteServices

extension RootViewModelFactory {
    
    /// - Warning: request is serial, but serial is ignored
    func loadServices(
        for payload: GetServicesForPayload,
        completion: @escaping ([ServicePickerItem]) -> Void
    ) {
        let getOperatorsListByParamOperatorOnlyFalse = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetOperatorsListByParamOperatorOnlyFalseRequest(payload:),
            mapResponse: RemoteServices.ResponseMapper.mapGetOperatorsListByParamOperatorOnlyFalseResponse(_:_:)
        )
        
        /// - Warning: request is serial, but serial is ignored
        getOperatorsListByParamOperatorOnlyFalse(.init(
            operatorID: payload.operatorID,
            type: payload.type,
            serial: nil
        )) {
            completion($0.services)
            _ = getOperatorsListByParamOperatorOnlyFalse
        }
    }
    
    /// `d`
    /// Получение услуг юр. лица по "customerId" и типу housingAndCommunalService
    /// dict/getOperatorsListByParam?customerId=8798&operatorOnly=false&type=housingAndCommunalService
    struct GetServicesForPayload: Equatable {
        
        let operatorID: String
        let type: String
    }
    
    typealias GetServicesForCompletion = ([UtilityService]) -> Void
}

// MARK: - Adapters

private typealias SberUtilityService = RemoteServices.ResponseMapper.SberUtilityService

private extension Result
where Success == [SberUtilityService] {
    
    var services: [ServicePickerItem] {
        
        return (try? get())?.servicePickerItems ?? []
    }
}

private extension Array
where Element == SberUtilityService {
    
    var servicePickerItems: [ServicePickerItem] {
        
        map { .init(service: $0.service, isOneOf: count > 1) }
    }
}
