//
//  BannersBoxInterface.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import Combine

protocol BannersBoxInterface<Banners> {
    
    associatedtype Banners
    
    var banners: AnyPublisher<Banners, Never> { get }
    func requestUpdate()
}
