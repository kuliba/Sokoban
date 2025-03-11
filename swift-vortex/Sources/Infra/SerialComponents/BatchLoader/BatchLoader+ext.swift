//
//  BatchLoader+ext.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

public extension BatchLoader {
    
    convenience init<Failure: Error>(
        load: @escaping (Payload, @escaping (Result<Response, Failure>) -> Void) -> Void
    ) {
        let store = Store()
        
        let batcher = Batcher { category, completion in
            
            load(category) {
                
                switch $0 {
                case let .failure(failure):
                    completion(failure)
                    
                case let .success(response):
                    store.update(key: category, with: response) { _ in
                        
                        completion(nil)
                    }
                }
            }
        }
        
        self.init(batcher: batcher, store: store)
    }
}
