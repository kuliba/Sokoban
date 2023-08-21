//
//  HTTPClient.swift
//
//
//  Created by Igor Malyarov on 27.07.2023.
//

import Foundation

public protocol HTTPClient {
    
    typealias Request = URLRequest
    typealias Response = (Data, HTTPURLResponse)
    typealias Result = Swift.Result<Response, Error>
    typealias Completion = (Result) -> Void
    
    func performRequest(
        _ request: Request,
        completion: @escaping Completion
    )
}
