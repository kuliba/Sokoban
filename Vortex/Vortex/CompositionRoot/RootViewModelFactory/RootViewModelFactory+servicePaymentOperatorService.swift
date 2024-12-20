//
//  RootViewModelFactory+servicePaymentOperatorService.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.09.2024.
//

import VortexTools
import OperatorsListBackendV0
import RemoteServices

extension RootViewModelFactory {
    
    typealias GetOperatorsListByParamPayload = Vortex.RequestFactory.GetOperatorsListByParamPayload
    typealias ServicePaymentProviderBatchService = BatchService<GetOperatorsListByParamPayload>
    
    @inlinable
    func servicePaymentOperatorService(
        payloads: [GetOperatorsListByParamPayload],
        completion: @escaping ([GetOperatorsListByParamPayload]) -> Void
    ) {
        let composed = batchServiceComposer.compose(
            makeRequest: Vortex.RequestFactory.getOperatorsListByParam,
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

extension Vortex.RequestFactory.GetOperatorsListByParamPayload {
    
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
    
    init(
        providers: [RemoteServices.ResponseMapper.ServicePaymentProvider]
    ) {
        self.init(
            providers: providers, 
            priority: { $0.characterSortPriority() }
        )
    }
    
    init(
        providers: [RemoteServices.ResponseMapper.ServicePaymentProvider],
        priority: (Character) -> Int
    ) {
        let decorated = providers.map {
            
            (provider: $0, 
             nameSortKey: $0.nameSortKey(priority: priority),
             innSortKey: $0.innSortKey(priority: priority))
        }
        
        let sorted = decorated.sorted {
            
            if $0.nameSortKey != $1.nameSortKey {
                return $0.nameSortKey < $1.nameSortKey
            } else {
                return $0.innSortKey < $1.innSortKey
            }
        }
        
        self = sorted
            .map(\.provider)
            .enumerated()
            .map(CodableServicePaymentOperator.init)
    }
}

extension RemoteServices.ResponseMapper.ServicePaymentProvider {
    
    @inlinable
    func nameSortKey(priority: (Character) -> Int) -> SortKey {
        
        return .init(string: name, priority: priority)
    }
    
    @inlinable
    func innSortKey(priority: (Character) -> Int) -> SortKey {
        
        return .init(string: inn, priority: priority)
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
