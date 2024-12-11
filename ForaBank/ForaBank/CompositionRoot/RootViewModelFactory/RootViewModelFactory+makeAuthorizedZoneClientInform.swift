//
//  RootViewModelFactory+makeAuthorizedZoneClientInform.swift
//  ForaBank
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
            
            _createGetAuthorizedZoneClientInformData(()) { result in
                
                switch result {
                case .failure:
                    completion(nil)
                    
                case let .success(response):
                    
                    let list = response.list.compactMap { GetAuthorizedZoneClientInformData.init($0) }
                  
                    list.count == 1 && list.first != nil ?
                    completion(.init(list,
                            infoLabel: .init(
                                image: list.first?.image,
                                title: list.first?.title ?? "Информация"))
                    )
                    : completion(.init(list,
                            infoLabel: .init(
                                image: nil,
                                title: "Информация"))
                    )
                }
                
                _ = _createGetAuthorizedZoneClientInformData
            }
        }
        
        createGetAuthorizedZoneClientInformData {
            
            if let info = $0 {
                
                self.logger.log(level: .info, category: .network, message: "notifications \(info)", file: #file, line: #line)
                self.model.сlientAuthorizationState.value.authorized = info
            } else {
                
                self.logger.log(level: .error, category: .network, message: "failed to fetch authorizedZoneClientInformData", file: #file, line: #line)
            }
            
            _ = createGetAuthorizedZoneClientInformData
        }
        
        func extractImage(from item: GetAuthorizedZoneClientInformData) -> Image? { return item.image }
    }
}
