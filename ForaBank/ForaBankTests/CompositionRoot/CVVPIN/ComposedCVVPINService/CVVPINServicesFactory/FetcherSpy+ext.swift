//
//  FetcherSpy+ext.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.11.2023.
//

import Fetcher

extension FetcherSpy
where Payload == Void {
    
    func fetch(completion: @escaping FetchCompletion) {
        
        fetch((), completion: completion)
    }
}
