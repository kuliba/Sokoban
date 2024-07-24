//
//  ChangeSVCardLimitServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.07.2024.
//

import Foundation
import SVCardLimitAPI
import RemoteServices

struct ChangeSVCardLimitServices {
    
    typealias CreateChangeSVCardLimit = (ChangeSVCardLimitPayload, @escaping ChangeSVCardLimitCompletion) -> Void
    typealias ChangeSVCardLimitResult = Result<Void, MappingError>
    typealias ChangeSVCardLimitCompletion = (ChangeSVCardLimitResult) -> Void
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>

    typealias ChangeSVCardLimitsCompletion = (String?) -> Void

    private let createChangeSVCardLimit: CreateChangeSVCardLimit
    
    init(
        createChangeSVCardLimit: @escaping CreateChangeSVCardLimit
    ) {
        self.createChangeSVCardLimit = createChangeSVCardLimit
    }
    
    func сhangeSVCardLimits(
        payloads: [ChangeSVCardLimitPayload],
        completion: @escaping ChangeSVCardLimitsCompletion
    ) {
        let dispatchGroup = DispatchGroup()
        var errors: [MappingError] = []
        
        for payload in payloads {
            dispatchGroup.enter()
            
            DispatchQueue.global().sync {
                
                createChangeSVCardLimit(payload) {
                    if case let .failure(err) = $0 {
                        errors.append(err)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            
            if !errors.isEmpty {
                
                completion(errorMessages(errors))
            } else {
                completion(nil)
            }
        }
    }
}

private extension ChangeSVCardLimitServices {
    
    func errorMessages(_ errors: [MappingError]) -> String {
        
        let messages: [String] = {
            
            errors.map {
                errorMessage($0)
            }
        }()

        return messages.uniqued().joined(separator: "\n")
    }
    
    func errorMessage(_ error: MappingError) -> String {
        
        switch error {
            
        case .createRequest, .performRequest:
            return .changeSVCardLimitDefaultError
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
                
            case .invalid:
                return .changeSVCardLimitDefaultError
                
            case let .server(statusCode: _, errorMessage: errorMessage):
                return errorMessage
            }
        }
    }
}

private extension String {
    
    static let changeSVCardLimitDefaultError: Self = "Что-то пошло не так.\nПопробуйте позже"
}

// MARK: - Preview Content

extension ChangeSVCardLimitServices {
    
    static func preview() -> Self {
        
        .init(createChangeSVCardLimit: { _, completion in
            
            completion(.success(()))
        })
    }
    
    static func preview(
        createChangeSVCardLimitStub: ChangeSVCardLimitResult
    ) -> Self {
        
        .init(
            createChangeSVCardLimit: { _, completion in
                
                completion(createChangeSVCardLimitStub)
            }
        )
    }
}

