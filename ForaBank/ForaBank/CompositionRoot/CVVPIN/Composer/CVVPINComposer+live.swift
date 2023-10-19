//
//  CVVPINComposer+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import CVVPINServices
import Security

extension CVVPINComposer
where RemoteCVV == ForaBank.RemoteCVV,
      RSAPrivateKey == SecKey,
      RSAPublicKey == SecKey,
      SymmetricKey == ForaBank.SymmetricKey,
      SessionID == ForaBank.SessionID,
      ShowCVVAPIError == RemoteServiceErrorOf<ResponseMapper.ShowCVVMapperError>,
      ChangePINAPIError == RemoteServiceErrorOf<ResponseMapper.ChangePINMappingError>,
      KeyServiceAPIError == RemoteServiceErrorOf<ResponseMapper.KeyExchangeMapperError> {
    
    static func live(
        httpClient: HTTPClient
    ) -> CVVPINComposer {
        
        .init(
            crypto: .live(httpClient: httpClient),
            infra: .live(httpClient: httpClient),
            remote: .live(httpClient: httpClient)
        )
    }
}
