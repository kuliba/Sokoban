//
//  Services+getProcessingSessionCode.swift
//  Vortex
//
//  Created by Igor Malyarov on 31.07.2023.
//

import CvvPin
import GetProcessingSessionCodeService

extension Services {
    
    typealias GetProcessingSessionCode = GetProcessingSessionCodeService
    
    static func getProcessingSessionCode(
        httpClient: HTTPClient
    ) -> GetProcessingSessionCode {
        
        let endpoint = Services.Endpoint.getProcessingSessionCode
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        return GetProcessingSessionCode(
            url: url,
            performRequest: httpClient.performRequest(_:completion:)
        )
    }
}

extension Services.GetProcessingSessionCode: SessionCodeLoader {
    
    public func load(completion: @escaping LoadCompletion) {
        
        process { result in
            
            completion(
                result
                    .map(SessionCodeMapper.map)
                    .mapError { $0 }
            )
        }
    }
    
    private enum SessionCodeMapper {
        
        static func map(
            _ code: SessionCodeDomain.GetProcessingSessionCode
        ) -> GetProcessingSessionCodeDomain.SessionCode {
            
            .init(value: code.code)
        }
    }
}
