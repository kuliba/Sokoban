//
//  Services+failingKeyExchangeService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import TransferPublicKey
import CvvPin
import Foundation
import GenericRemoteService

//extension Services {
//
//    static func failingKeyExchangeService(
//        httpClient: HTTPClient,
//        privateKey: SecKey,
//        transportPublicRSAKey: SecKey
//    ) -> KeyExchangeServiceProtocol {
//
//        let bindPublicKeyWithEventIDService: RemoteService<PublicKeyWithEventID, Result<OK, BindPublicKeyWithEventIDMapper.Error>> = RemoteService(
//            createRequest: RequestFactory.makeBindPublicKeyWithEventIDRequest,
//            performRequest: httpClient.performRequest,
//            mapResponse: BindPublicKeyWithEventIDMapper.mapResponse
//        )
//
//        let failingKeyExchangeService = FailingKeyExchangeService(
//            bindPublicKeyWithEventIDService: bindPublicKeyWithEventIDService,
//            privateKey: privateKey,
//            transportPublicRSAKey: transportPublicRSAKey
//        )
//
//        return failingKeyExchangeService
//    }
//}

//struct OK {}

//private extension BindPublicKeyWithEventIDMapper {
//
//    // adapter
//    static func mapResponse(
//        _ data: Data,
//        _ response: HTTPURLResponse
//    ) -> Swift.Result<OK, Error> {
//
//        if let error = map(data, response) {
//            return .failure(error)
//        } else {
//            return .success(.init())
//        }
//    }
//}

protocol CryptoAPIClient<Request, Response> {
    
    associatedtype Request
    associatedtype Response
    
    typealias Result = Swift.Result<Response, Error>
    typealias Completion = (Result) -> Void
    
    func get(
        _ request: Request,
        completion: @escaping Completion
    )
}

//protocol KeyExchangeServiceProtocol {
//
//    func exchangeKey(
//        with sessionCode: KeyExchangeDomain.SessionCode,
//        completion: @escaping KeyExchangeDomain.Completion
//    )
//}

//final class FailingKeyExchangeService: KeyExchangeServiceProtocol {
//
//    typealias MapperError = BindPublicKeyWithEventIDMapper.Error
//    typealias Result = Swift.Result<OK, MapperError>
//    typealias BindPublicKeyWithEventIDService = CryptoAPIClient<PublicKeyWithEventID, Result>
//
//    private let bindPublicKeyWithEventIDService: any BindPublicKeyWithEventIDService
//    private let privateKey: SecKey
//    private let transportPublicRSAKey: SecKey
//
//    init(
//        bindPublicKeyWithEventIDService: any BindPublicKeyWithEventIDService,
//        privateKey: SecKey,
//        transportPublicRSAKey: SecKey
//    ) {
//        self.bindPublicKeyWithEventIDService = bindPublicKeyWithEventIDService
//        self.privateKey = privateKey
//        self.transportPublicRSAKey = transportPublicRSAKey
//    }
//
//    func exchangeKey(
//        with sessionCode: KeyExchangeDomain.SessionCode,
//        completion: @escaping KeyExchangeDomain.Completion
//    ) {
//        let error = NSError(domain: "FailingKeyExchangeService exchangeKey error", code: 0)
//        completion(.failure(error))
//    }
//
//    func extractSymmetricKey(
//        with payload: KeyExchangeDomain.KeyExchange,
//        completion: @escaping SharedSecretDomain.Completion
//    ) {
//
//        do {
//
//            let serverPublicKey = try Crypto.serverPublicKey(
//                from: payload.sharedSecret.base64EncodedString(),
//                using: transportPublicRSAKey
//            )
//
//            let sharedSecretData = try CSRFAgent<AESEncryptionAgent>.sharedSecretData(privateKey, serverPublicKey)
//            _ = sharedSecretData
//        } catch {
//
//            fatalError()
//        }
//
//
//        let publicKeyWithEventID = PublicKeyWithEventID(
//            key: .init(keyData: payload.sharedSecret),
//            eventID: .init(value: payload.eventID.value)
//        )
//
//        bindPublicKeyWithEventIDService.get(publicKeyWithEventID) { _ in
//
//            let error = NSError(domain: "FailingKeyExchangeService error", code: 0)
//            completion(.failure(error))
//        }
//    }
//}
