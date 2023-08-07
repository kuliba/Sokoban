//
//  TokenProvider.swift
//
//
//  Created by Igor Malyarov on 27.07.2023.
//

public protocol TokenProvider {
    
    typealias Token = String
    typealias GetTokenResult = Result<Token, Error>
    typealias Completion = (GetTokenResult) -> Void
    
    func getToken(completion: @escaping Completion)
}
