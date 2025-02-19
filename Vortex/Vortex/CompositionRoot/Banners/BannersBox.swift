//
//  BannersBox.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import Combine

final class BannersBox<Banners> {
    
    typealias Load = (@escaping (Banners?) -> Void) -> Void
    
    private let updateSubject = PassthroughSubject<Banners, Never>()
    private let load: Load
    
    init(load: @escaping Load) {
        
        self.load = load
    }
    
    var banners: AnyPublisher<Banners, Never> {
        
        updateSubject.eraseToAnyPublisher()
    }

    func update() {
        
        load { [weak updateSubject] banners in
            if let banners {
                updateSubject?.send(banners)
            }
        }
    }
}

extension BannersBox: BannersBoxInterface {
    
    func requestUpdate() {
        update()
    }
}
