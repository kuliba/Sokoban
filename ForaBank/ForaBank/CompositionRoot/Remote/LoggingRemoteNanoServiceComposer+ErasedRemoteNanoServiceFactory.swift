//
//  LoggingRemoteNanoServiceComposer+ErasedRemoteNanoServiceFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

extension LoggingRemoteNanoServiceComposer: ErasedRemoteNanoServiceFactory {

    func compose<Payload, Response>(
        createRequest: @escaping CreateRequest<Payload>,
        mapResponse: @escaping MapResponse<Response, Error>
    ) -> NanoService<Payload, Response, Error> {
        
        compose(
            createRequest: createRequest,
            mapResponse: mapResponse,
            mapError: { $0 },
            file: #file, line: #line
        )
    }
}
