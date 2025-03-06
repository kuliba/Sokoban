//
//  WeakBox.swift
//
//
//  Created by Igor Malyarov on 06.03.2025.
//

/// A box that holds a weak reference to a model.
/// This is used to store models in the cache without creating strong reference cycles.
public struct WeakBox<Model: AnyObject> {
    
    public weak var model: Model?
    
    public init(model: Model? = nil) {
        
        self.model = model
    }
}
