//
//  ViewComponents+makeSavingsAccountInfo.swift
//  Vortex
//
//  Created by Andryusina Nataly on 13.03.2025.
//

import SavingsAccount

extension ViewComponents {
    
    func makeSavingsAccountInfo(
        info: SavingsAccountInfo,
        config: SavingsAccountInfoConfig = .iVortex
    ) -> SavingsAccount.InfoView {
        
        .init(info: info, config: config)
    }
}
