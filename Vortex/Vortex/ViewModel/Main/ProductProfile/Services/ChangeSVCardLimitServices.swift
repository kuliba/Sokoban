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
    
    typealias ChangeSVCardLimitsCompletion = (String?, [GetSVCardLimitsResponse.LimitItem]?) -> Void
    
    private let createChangeSVCardLimit: CreateChangeSVCardLimit
    private let createGetSVCardLimits: GetSVCardLimitsServices.CreateGetSVCardLimits
    
    init(
        createChangeSVCardLimit: @escaping CreateChangeSVCardLimit,
        createGetSVCardLimits: @escaping GetSVCardLimitsServices.CreateGetSVCardLimits
    ) {
        self.createChangeSVCardLimit = createChangeSVCardLimit
        self.createGetSVCardLimits = createGetSVCardLimits
    }
    
    func сhangeSVCardLimits(
        card: ProductCardData,
        payloads: [ChangeSVCardLimitPayload],
        completion: @escaping ChangeSVCardLimitsCompletion
    ) {
        let dispatchGroup = DispatchGroup()
        var errors: [MappingError] = []
        
        for payload in payloads {
            dispatchGroup.enter()
            
            DispatchQueue.global(qos: .background).sync {
                
                createChangeSVCardLimit(payload) {
                    if case let .failure(err) = $0 {
                        errors.append(err)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .background)) {
            
            if !errors.isEmpty {
                
                completion(errorMessages(errors), nil)
            } else {
                
                DispatchQueue.global(qos: .background).sync {
                    
                    createGetSVCardLimits((.init(cardId: card.cardId))) {
                        switch $0 {
                            
                        case let .success(limits):
                            completion(nil, limits.limitsList)
                            
                        case let .failure(err):
                            completion(errorMessages([err]), nil)                        }
                    }
                }
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
        
        .init(
            createChangeSVCardLimit: { _, completion in
                
                completion(.success(()))
            },
            createGetSVCardLimits: { _, completion in
                
                completion(.success(.init(limitsList: [.init(type: "Debit", limits: [.init(currency: 810, currentValue: 10, name: "Limit", value: 10)])], serial: "11")))
            }
        )
    }
    
    static func preview(
        createChangeSVCardLimitStub: ChangeSVCardLimitResult,
        createGetSVCardLimitsStub: GetSVCardLimitsServices.GetSVCardLimitsResult
    ) -> Self {
        
        .init(
            createChangeSVCardLimit: { _, completion in
                
                completion(createChangeSVCardLimitStub)
            }, 
            createGetSVCardLimits: { _, completion in
                
                completion(createGetSVCardLimitsStub)
            }
        )
    }
}

