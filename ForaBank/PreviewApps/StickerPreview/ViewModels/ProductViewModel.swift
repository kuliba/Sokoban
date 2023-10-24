//
//  ProductViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import SwiftUI
import Foundation

struct ProductViewModel {
    
    let header: HeaderViewModel
    let main: MainViewModel
    let footer: FooterViewModel
}

extension ProductViewModel {
    
    struct MainViewModel {
    
        let cardLogo: Image
        let paymentSystem: Image?
        let name: String
        let balance: String
    }
    
    struct HeaderViewModel {
        
        let title: String
    }
    
    struct FooterViewModel {
        
        let description: String
    }
}
