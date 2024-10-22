//
//  LoggingRemoteNanoServiceComposer+composeGetLatestPayments.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.10.2024.
//

import RemoteServices

extension LoggingRemoteNanoServiceComposer {
    
    func composeGetLatestPayments(
    ) -> RemoteDomain<[String], [Latest], Error, Error>.Service {
        
        self.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
    }
}
