//
//  Model+TokenProvider.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2023.
//

import Foundation
import ServerAgent

extension Model: TokenProvider {
    
    func getToken(completion: @escaping Completion) {
        
        if let token {
            completion(.success(token))
        } else {
            completion(.failure(ServerAgentError.notAuthorized))
        }
    }
}
