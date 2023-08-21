//
//  ActiveSessionAgentStub.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.02.2023.
//

import Combine
@testable import ForaBank
import Foundation

final class ActiveSessionAgentStub: SessionAgentProtocol {
    
    var action: PassthroughSubject<Action, Never> = .init()
    
    var sessionState: CurrentValueSubject<SessionState, Never> {
        
        let token = UUID().uuidString
        let csrfAgent = CSRFAgentDummy.dummy
        let credentials: SessionCredentials = .init(
            token: token,
            csrfAgent: csrfAgent
        )
        let state = SessionState.active(
            start: 0,
            credentials: credentials
        )
        
        return .init(state)
    }
}

final class CSRFAgentDummy: CSRFAgentProtocol {
    
    let publicKeyData = "CSRFAgentDummy"
    
    typealias Agent = EncryptionAgentDummy
    
    init(
        _ keysProvider: EncryptionKeysProvider,
        _ serverCertificatesData: String,
        _ serverPublicKeyEncrypted: String
    ) throws {}
    
    func encrypt(_ stringData: String) throws -> String { stringData }
    func decrypt(_ stringData: String) throws -> String { stringData }
    
    static let dummy: CSRFAgentDummy = try! .init(
        EncryptionKeysProviderDummy(),
        "serverCertificatesData",
        "serverPublicKeyEncrypted"
    )
}

final class EncryptionAgentDummy: EncryptionAgent {
    
    init(with keyData: Data) {}
    
    func encrypt(_ data: Data) throws -> Data { data }
    func decrypt(_ data: Data) throws -> Data { data }
}

private final class EncryptionKeysProviderDummy: EncryptionKeysProvider {
    
    func generateKeysPair() throws -> EncryptionKeysPair {
        throw NSError(domain: "EncryptionKeysPair Generation failed", code: 0)
    }
}
