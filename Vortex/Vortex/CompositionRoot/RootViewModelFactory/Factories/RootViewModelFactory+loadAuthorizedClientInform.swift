//
//  RootViewModelFactory+loadAuthorizedClientInform.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.03.2025.
//

import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func loadAuthorizedClientInform(
        completion: @escaping (ClientInformListDataState?) -> Void
    ) {
        let createGetAuthorizedZoneClientInformData = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAuthorizedZoneClientInformDataRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetAuthorizedZoneClientInformDataResponse
        )
        
        createGetAuthorizedZoneClientInformData(()) {
            
            completion((try? $0.get())?.list)
            _ = createGetAuthorizedZoneClientInformData
        }
    }
}

// MARK: - Adapters

private extension RemoteServices.ResponseMapper.GetAuthorizedZoneClientInformDataResponse {
    
    var list: ClientInformListDataState? {
        
        let list = self.list.compactMap { GetAuthorizedZoneClientInformData.init($0) }
        
        return .init(
            list,
            infoLabel: .init(
                image: list.first?.image,
                title: list.first?.title ?? "Информация"
            )
        )
    }
}
