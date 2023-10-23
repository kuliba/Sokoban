//
//  CVVPINRemote+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.10.2023.
//

import CVVPINServices
import Foundation
import GenericRemoteService

typealias RemoteServiceErrorOf<APIError> = RemoteServiceError<Error, Error, APIError>

extension CVVPINRemote
where RemoteCVV == ForaBank.RemoteCVV,
      SessionID == ForaBank.SessionID,
      ShowCVVAPIError == RemoteServiceErrorOf<CVVPINServices.ResponseMapper.ShowCVVMapperError>,
      ChangePINAPIError == RemoteServiceErrorOf<CVVPINServices.ResponseMapper.ChangePINMappingError>,
      KeyServiceAPIError == RemoteServiceErrorOf<CVVPINServices.ResponseMapper.KeyExchangeMapperError> {
    
    static func live(
        httpClient: HTTPClient,
        currentDate: @escaping () -> Date = Date.init
    ) -> Self {
        
        let changePINService = RemoteService(
            createRequest: RequestFactory.makeChangePINRequestResult,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: CVVPINServices.ResponseMapper.mapChangePINResponse
        )
        
        let cvvService = RemoteService(
            createRequest: RequestFactory.makeShowCVVRequestResult,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: CVVPINServices.ResponseMapper.mapShowCVVResponse
        )
        
        let keyService = RemoteService(
            createRequest: RequestFactory.makeProcessPublicKeyAuthenticationRequestResult,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: CVVPINServices.ResponseMapper.mapProcessPublicKeyAuthenticationResponse
        )
        
        return .init(
            changePINProcess: changePINService.process(_:completion:),
            remoteCVVProcess: cvvService.process(request:completion:),
            keyAuthProcess: keyService.process(_:completion:)
        )
    }
}

// MARK: - Adapters

private extension RemoteService<(SessionID, Data), CVVPINServices.RemoteCVV, Error, Error, CVVPINServices.ResponseMapper.ShowCVVMapperError> {
    
    typealias Error = RemoteServiceErrorOf<CVVPINServices.ResponseMapper.ShowCVVMapperError>
    
    func process(
        request: (SessionID, Data),
        completion: @escaping (Result<RemoteCVV, Error>) -> Void
    ) {
        process(request) { result in
            
            completion(result.map { .init(value: $0.value) })
        }
    }
}

private extension RequestFactory {
    
    static func makeChangePINRequestResult(
        sessionID: SessionID,
        data: Data
    ) -> Result<URLRequest, Error> {
        
        .init {
            try makeChangePINRequest(sessionID: sessionID, data: data)
        }
    }
    
    static func makeShowCVVRequestResult(
        sessionID: SessionID,
        data: Data
    ) -> Result<URLRequest, Error> {
        
        .init {
            try makeShowCVVRequest(sessionID: sessionID, data: data)
        }
    }
    
    static func makeProcessPublicKeyAuthenticationRequestResult(
        data: Data
    ) -> Result<URLRequest, Error> {
        
        .init {
            try makeProcessPublicKeyAuthenticationRequest(
                data: data
            )
        }
    }
}

private extension CVVPINServices.ResponseMapper {
    
    static func mapProcessPublicKeyAuthenticationResponse(
        response: (
            data: Data,
            httpURLResponse: HTTPURLResponse
        )
    ) -> Result<PublicKeyAuthenticationResponse, KeyExchangeMapperError> {
        
        mapProcessPublicKeyAuthenticationResponse(
            response.data,
            response.httpURLResponse
        )
        .map { response in
            
                .init(
                    publicServerSessionKey: .init(value: response.publicServerSessionKey),
                    sessionID: .init(rawValue: response.sessionID),
                    sessionTTL: .init(response.sessionTTL)
                )
        }
    }
}
