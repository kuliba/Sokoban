//
//  RequestCollector+Loader.swift
//  
//
//  Created by Igor Malyarov on 01.07.2024.
//

extension RequestCollector: Loader {
    
    public func load(
        _ request: Request,
        _ completion: @escaping Completion
    ) {
        process(request, completion)
    }
}
