//
//  LoggingRemoteNanoServiceComposer+RemoteNanoServiceFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.09.2024.
//

import RemoteServices

extension LoggingRemoteNanoServiceComposer: RemoteNanoServiceFactory {
    
    func compose<Payload, Response>(
        makeRequest: @escaping RemoteDomainOf<Payload, Response, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomainOf<Payload, Response, Error>.MapResponse
    ) -> RemoteDomainOf<Payload, Response, Error>.Service {

        compose(createRequest: makeRequest, mapResponse: mapResponse)
    }
}
