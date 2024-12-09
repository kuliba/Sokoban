//
//  ComposedGetConsentListAndDefaultBankService.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

public final class ComposedGetConsentListAndDefaultBankService {
    
    public typealias GetConsentListResult = GetConsentListAndDefaultBankResults.ConsentListResult
    public typealias GetConsentListCompletion = (GetConsentListResult) -> Void
    public typealias GetConsentList = (@escaping GetConsentListCompletion) -> Void
    
    public typealias GetDefaultBankResult = GetConsentListAndDefaultBankResults.DefaultBankResult
    public typealias GetDefaultBankCompletion = (GetDefaultBankResult) -> Void
    public typealias GetDefaultBank = (PhoneNumber, @escaping GetDefaultBankCompletion) -> Void
    
    private let getConsentList: GetConsentList
    private let getDefaultBank: GetDefaultBank
    
    public init(
        getConsentList: @escaping GetConsentList,
        getDefaultBank: @escaping GetDefaultBank
    ) {
        self.getConsentList = getConsentList
        self.getDefaultBank = getDefaultBank
    }
}

public extension ComposedGetConsentListAndDefaultBankService {
    
    typealias Completion = (GetConsentListAndDefaultBankResults) -> Void
    
    func process(
        _ payload: PhoneNumber,
        completion: @escaping Completion
    ) {
        getConsentList { [weak self] in
            
            self?._getDefaultBank(payload, $0, completion)
        }
    }
}

private extension ComposedGetConsentListAndDefaultBankService {
    
    func _getDefaultBank(
        _ payload: PhoneNumber,
        _ getConsentListResult: GetConsentListResult,
        _ completion: @escaping Completion
    ) {
        getDefaultBank(payload) { [weak self] in
            
            guard self != nil else { return }
            
            completion(.init(
                consentListResult: getConsentListResult,
                defaultBankResult: $0
            ))
        }
    }
}
