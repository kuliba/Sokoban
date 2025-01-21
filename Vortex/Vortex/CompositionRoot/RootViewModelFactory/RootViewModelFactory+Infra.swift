//
//  RootViewModelFactory+Infra.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.01.2025.
//

extension RootViewModelFactory {
    
    struct Infra {
        
        let imageCache: ImageCache
    }
}

extension RootViewModelFactory.Infra {
    
    init(model: Model) {
        
        self.imageCache = model.imageCache()
    }
}
