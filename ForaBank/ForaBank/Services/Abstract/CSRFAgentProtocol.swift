//
//  CSRFAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 23.01.2022.
//

import Foundation

protocol CSRFAgentProtocol {
    
    func createSharedSecret(with serverCertificatesData: String, serverPublicKeyEncrypted: String) throws -> Data
}
