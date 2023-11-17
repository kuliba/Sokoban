//
//  CVVPINRemote.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public struct CVVPINRemote<RemoteCVV, SessionID, ChangePINAPIError, KeyServiceAPIError, ShowCVVAPIError>
where ChangePINAPIError: Error,
      KeyServiceAPIError: Error,
      ShowCVVAPIError: Error {
    
    public typealias RemoteDomain<Success, Failure: Error> = RemoteServiceDomain<(SessionID, Data), Success, Failure>
    
    public typealias ChangePINServiceDomain = RemoteDomain<Void, ChangePINAPIError>
    public typealias ChangePINProcess = ChangePINServiceDomain.AsyncGet
    
    public typealias ShowCVVServiceDomain = RemoteDomain<RemoteCVV, ShowCVVAPIError>
    public typealias ShowCVVProcess = ShowCVVServiceDomain.AsyncGet
    
    public typealias Response = PublicKeyAuthenticationResponse
    public typealias KeyAuthDomain = RemoteServiceDomain<Data, Response, KeyServiceAPIError>
    public typealias KeyAuthProcess = KeyAuthDomain.AsyncGet
        
    let changePINProcess: ChangePINProcess
    let showCVVProcess: ShowCVVProcess
    let keyAuthProcess: KeyAuthProcess
    
    public init(
        changePINProcess: @escaping ChangePINProcess,
        remoteCVVProcess: @escaping ShowCVVProcess,
        keyAuthProcess: @escaping KeyAuthProcess
    ) {
        self.changePINProcess = changePINProcess
        self.showCVVProcess = remoteCVVProcess
        self.keyAuthProcess = keyAuthProcess
    }
}
