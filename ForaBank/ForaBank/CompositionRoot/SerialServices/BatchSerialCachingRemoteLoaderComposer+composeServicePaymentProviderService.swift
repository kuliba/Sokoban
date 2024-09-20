//
//  BatchSerialCachingRemoteLoaderComposer+composeServicePaymentProviderService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.09.2024.
//

import OperatorsListBackendV0
import RemoteServices

extension BatchSerialCachingRemoteLoaderComposer {
    
    typealias GetOperatorsListByParamPayload = ForaBank.RequestFactory.GetOperatorsListByParamPayload
    typealias RemoteProvider = RemoteServices.ResponseMapper.ServicePaymentProvider
    typealias ServicePaymentProviderService = StringSerialRemoteDomain<GetOperatorsListByParamPayload, RemoteProvider>.BatchService
    
    func composeServicePaymentProviderService(
        getSerial: @escaping (GetOperatorsListByParamPayload) -> String?
    ) -> ServicePaymentProviderService {
        
        let composed = self.compose(
            getSerial: getSerial,
            makeRequest: ForaBank.RequestFactory.getOperatorsListByParam,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperatorsListByParamOperatorOnlyTrueResponse,
            toModel: [CodableServicePaymentProvider].init(providers:)
        )
        
        return { payloads, completion in
            
            let withStandard = payloads.filter(\.hasStandardFlow)
            
            guard !withStandard.isEmpty else { return completion([]) }
            
            composed(withStandard, completion)
        }
    }
}

extension ForaBank.RequestFactory.GetOperatorsListByParamPayload {
    
    var hasStandardFlow: Bool {
        
        category.paymentFlow == .standard
    }
}

struct CodableServicePaymentProvider: Codable, Identifiable {
    
    let id: String
    let inn: String
    let md5Hash: String?
    let name: String
    let type: String
}

extension Array where Element == CodableServicePaymentProvider {
    
    init(providers: [RemoteServices.ResponseMapper.ServicePaymentProvider]) {
        
        self = providers.map(\.codable)
    }
}

private extension RemoteServices.ResponseMapper.ServicePaymentProvider {
    
    var codable: CodableServicePaymentProvider {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type)
    }
}
