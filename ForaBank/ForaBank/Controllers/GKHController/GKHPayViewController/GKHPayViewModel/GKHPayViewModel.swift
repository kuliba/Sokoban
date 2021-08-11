//
//  GKHPayViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import Foundation

//GKHPayViewModel.swift
class GKHPayViewModel<R: Resource> {
    
    private var state: R? {
        didSet {
            bind?(state)
        }
    }
    
    var bind: ((R?) -> Void)?
    
    func fetch () {
        R.fetch {[ weak self ] data in
            self?.state = data
        }
    }
}
