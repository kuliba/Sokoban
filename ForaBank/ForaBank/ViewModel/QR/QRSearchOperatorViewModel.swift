//
//  QRSearchOperatorViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI
import Combine

class QRSearchOperatorViewModel: ObservableObject {
    
    let operators: [OperatorGroupData.OperatorData]
    @Published var isLinkActive: Bool = false
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    
    init(operators: [OperatorGroupData.OperatorData]) {
        self.operators = operators
    }
    
    enum Link {
        
        case serchRegion
    }
}
