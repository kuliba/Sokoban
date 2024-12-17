//
//  LoggingRemoteNanoServiceComposer+ErasedRemoteNanoServiceFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

extension LoggingRemoteNanoServiceComposer: ErasedRemoteNanoServiceFactory {

    func compose<Payload, Response>(
        createRequest: @escaping RemoteDomain<Payload, Response, Error, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomain<Payload, Response, Error, Error>.MapResponse
    ) -> RemoteDomain<Payload, Response, Error, Error>.Service {
        
        compose(
            createRequest: createRequest,
            mapResponse: mapResponse,
            mapError: { $0 },
            file: #file, line: #line
        )
    }
}
