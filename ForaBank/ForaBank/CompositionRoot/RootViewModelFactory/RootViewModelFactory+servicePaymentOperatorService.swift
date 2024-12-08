//
//  RootViewModelFactory+servicePaymentOperatorService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.09.2024.
//

import OperatorsListBackendV0
import RemoteServices

extension RootViewModelFactory {
    
    typealias GetOperatorsListByParamPayload = ForaBank.RequestFactory.GetOperatorsListByParamPayload
    typealias ServicePaymentProviderBatchService = BatchService<GetOperatorsListByParamPayload>
    
    @inlinable
    func servicePaymentOperatorService(
        payloads: [GetOperatorsListByParamPayload],
        completion: @escaping ([GetOperatorsListByParamPayload]) -> Void
    ) {
        let composed = batchServiceComposer.compose(
            makeRequest: ForaBank.RequestFactory.getOperatorsListByParam,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperatorsListByParamOperatorOnlyTrueResponse,
            toModel: [CodableServicePaymentOperator].init(providers:)
        )
        
        let withStandard = payloads.filter(\.hasStandardFlow)
        
        guard !withStandard.isEmpty else { return completion([]) }
        
        composed(withStandard) { [batchServiceComposer, composed] in
            
            completion($0); 
            _ = batchServiceComposer
            _ = composed
        }
    }
}

extension ForaBank.RequestFactory.GetOperatorsListByParamPayload {
    
    var hasStandardFlow: Bool {
        
        category.paymentFlow == .standard
    }
}

struct CodableServicePaymentOperator: Codable, Equatable, Identifiable {
    
    let id: String
    let inn: String
    let md5Hash: String?
    let name: String
    let type: String
    let sortedOrder: Int
}

extension Array where Element == CodableServicePaymentOperator {
    
    init(providers: [RemoteServices.ResponseMapper.ServicePaymentProvider]) {
        
        self = providers
            .sorted { $0.precedes($1) }
            .enumerated()
            .map(CodableServicePaymentOperator.init(_:_:))
    }
}

extension RemoteServices.ResponseMapper.ServicePaymentProvider {
    
    func precedes(_ other: Self) -> Bool {
        
        guard name == other.name
        else {
            return name.customLexicographicallyPrecedes(other.name)
        }
        
        return inn.customLexicographicallyPrecedes(other.inn)
    }
}

private extension CodableServicePaymentOperator {
    
    init(
        _ sortedOrder: Int,
        _ provider: RemoteServices.ResponseMapper.ServicePaymentProvider
    ) {
        self.init(
            id: provider.id,
            inn: provider.inn,
            md5Hash: provider.md5Hash,
            name: provider.name,
            type: provider.type,
            sortedOrder: sortedOrder
        )
    }
}
