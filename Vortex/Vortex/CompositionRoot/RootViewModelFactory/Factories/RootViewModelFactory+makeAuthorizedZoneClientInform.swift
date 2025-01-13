//
//  RootViewModelFactory+makeAuthorizedZoneClientInform.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 11.12.2024.
//

import Combine
import Foundation
import RemoteServices
import SwiftUI

extension RootViewModelFactory {
    
    @inlinable
    func updateAuthorizedClientInform() {
        
        let _createGetAuthorizedZoneClientInformData = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAuthorizedZoneClientInformDataRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetAuthorizedZoneClientInformDataResponse
        )
        let createGetAuthorizedZoneClientInformData = { (completion: @escaping (ClientInformListDataState?) -> Void) in
            
            _createGetAuthorizedZoneClientInformData(()) {
                
                completion($0.list)
                
                _ = _createGetAuthorizedZoneClientInformData
            }
        }
        
        createGetAuthorizedZoneClientInformData {
            
            if let info = $0 {
                
                self.logger.log(level: .info, category: .network, message: "notifications \(info)", file: #file, line: #line)
                self.model.clientAuthorizationState.value.authorized = info
            } else {
                
                self.logger.log(level: .error, category: .network, message: "failed to fetch authorizedZoneClientInformData", file: #file, line: #line)
            }
            
            _ = createGetAuthorizedZoneClientInformData
        }
        
        func extractImage(from item: GetAuthorizedZoneClientInformData) -> Image? { return item.image }
    }
}

// MARK: Adapters

extension Result where Success ==  RemoteServices.ResponseMapper.GetAuthorizedZoneClientInformDataResponse {
    
    var list: ClientInformListDataState? {
        
        try? self.map(\.list).get()
    }
}

private extension RemoteServices.ResponseMapper.GetAuthorizedZoneClientInformDataResponse {
        
    var list: ClientInformListDataState? {
        
        let list = self.list.compactMap { GetAuthorizedZoneClientInformData.init($0) }

        return .init(list,
                infoLabel: .init(
                    image: list.first?.image,
                    title: list.first?.title ?? "Информация"))
    }
}
