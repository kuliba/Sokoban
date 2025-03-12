//
//  AuthLandingDomain.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 06.03.2025.
//

import Foundation
import RxViewModel

enum AuthProductsLandingDomain {}

extension AuthProductsLandingDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = AuthProductsViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable {
        
        case productID(Int)
    }
    
    enum Navigation {

        case productID(Int)
    }
}
