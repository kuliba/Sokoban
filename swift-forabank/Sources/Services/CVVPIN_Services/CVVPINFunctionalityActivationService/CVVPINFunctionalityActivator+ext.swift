//
//  CVVPINFunctionalityActivationService+ext.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

/// - Note: `SessionKey` is `SymmetricKey` is `SharedSecret`
///
extension CVVPINFunctionalityActivationService {
    
    convenience init(
        getCodeService: GetProcessingSessionCodeService,
        cacheGetCode: @escaping (GetProcessingSessionCodeService.Response) -> Void,
        formSessionKeyService: FormSessionKeyService,
        cacheSessionKey: @escaping (FormSessionKeyService.SessionKey) -> Void,
        bindPublicKeyWithEventIDService: BindPublicKeyWithEventIDService,
        clearCache: @escaping () -> Void
    ) {
        let getCodeService = CachingGetProcessingSessionCodeServiceDecorator(
            decoratee: getCodeService,
            cache: cacheGetCode
        )
        let formSessionKeyService = CachingFormSessionKeyServiceDecorator(
            decoratee: formSessionKeyService,
            cache: cacheSessionKey
        )
        let bindPublicKeyWithEventIDService = RSAKeyPairCacheCleaningBindPublicKeyWithEventIDServiceDecorator(
            decoratee: bindPublicKeyWithEventIDService,
            clearCache: clearCache
        )
        
        self.init(
            getCode: { completion in
                
                getCodeService.getCode { [completion] result in
                    
                    completion(
                        result
                            .map(GetCodeResponse.init)
                            .mapError { _ in Error.getCodeFailure}
                    )
                }
            },
            formSessionKey: { completion in
                
                formSessionKeyService.formSessionKey { [completion] result in
                    
                    completion(
                        result
                            .map(CVVPINFunctionalityActivationService.SessionKey.init)
                            .mapError { _ in Error.formSessionKeyFailure }
                    )
                }
            },
            bindPublicKeyWithEventID: { otp, completion in
                
                bindPublicKeyWithEventIDService.bind(
                    otp: .init(otp: otp.otp)
                ) { [completion] result in
                    
                    completion(result.mapError { _ in Error.bindKeyFailure })
                }
            }
        )
    }
}

private extension CVVPINFunctionalityActivationService.SessionKey {
    
    init(
        _ key: FormSessionKeyService.SessionKey
    ) {
        self.init(sessionKey: key.sessionKey)
    }
}

private extension CVVPINFunctionalityActivationService.GetCodeResponse {
    
    init(response: GetProcessingSessionCodeService.Response) {
        
        self.init(code: response.code, phone: response.phone)
    }
}
