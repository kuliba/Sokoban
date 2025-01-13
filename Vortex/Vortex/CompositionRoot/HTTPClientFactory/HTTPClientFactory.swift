//
//  HTTPClientFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.10.2024.
//

protocol HTTPClientFactory {
    
    func makeHTTPClient() -> HTTPClient
}
