//
//  Services+getProcessingSessionCode.swift
//  ForaBank
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
        let url = try! endpoint.url(withBase: Config.serverAgentEnvironment.baseURL)
        
        return GetProcessingSessionCodeService(
            url: url,
            performRequest: httpClient.performRequest(_:completion:)
        )
    }
}

extension Services.GetProcessingSessionCode: SessionCodeLoader {
    
    public func load(completion: @escaping LoadCompletion) {
        
        process { result in
            
            completion(.init{
                
                try result.map(SessionCodeMapper.map).get()
            })
        }
    }
    
    private enum SessionCodeMapper {
        
        static func map(
            _ code: GetProcessingSessionCode
        ) -> SessionCode {
            
            .init(value: code.code)
        }
    }
}
