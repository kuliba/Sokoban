//
//  RootInfra.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.01.2025.
//

struct RootInfra {
    
    let imageCache: ImageCache
}

extension RootInfra {
    
    init(model: Model) {
        
        self.imageCache = model.imageCache()
    }
}
