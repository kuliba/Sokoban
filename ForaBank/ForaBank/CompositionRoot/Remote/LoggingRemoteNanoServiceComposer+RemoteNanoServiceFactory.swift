//
//  LoggingRemoteNanoServiceComposer+RemoteNanoServiceFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.09.2024.
//

extension LoggingRemoteNanoServiceComposer: RemoteNanoServiceFactory {
    
    func compose<Payload, Response>(
        makeRequest: @escaping MakeRequest<Payload>,
        mapResponse: @escaping Map<Response>
    ) -> Service<Payload, Response> {
        
        compose(createRequest: makeRequest, mapResponse: mapResponse)
    }
}
