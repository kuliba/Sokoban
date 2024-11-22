//
//  RootViewModelFactory+getSberQRData.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation
import SberQR

extension RootViewModelFactory {
    
    func getSberQRData(
        url: URL,
        completion: @escaping (Result<GetSberQRDataResponse, any Error>) -> Void
    ) {
        let getSberQRData = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetSberQRRequest,
            mapResponse: SberQR.ResponseMapper.mapGetSberQRDataResponse,
            mapError: { $0 }
        )
        
        getSberQRData(url) {
            
            completion($0.mapError { $0 })
            _ = getSberQRData
        }
    }
}
