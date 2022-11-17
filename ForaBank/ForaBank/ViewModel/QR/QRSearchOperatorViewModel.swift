//
//  QRSearchOperatorViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI
import Combine

class QRSearchOperatorViewModel: ObservableObject {
    
    @Published var isLinkActive: Bool = false
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    
    
    
    enum Link {
        
        case serchRegion
    }
}
