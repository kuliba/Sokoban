//
//  ContentViewModelComposer.swift
//  CollateralLoanLandingPreview
//
//  Created by Valentin Ozerov on 06.11.2024.
//

import Foundation

final class ContentViewModelComposer {
    
    func compose() -> ContentViewDomain.Flow {
        
        let composer = ContentViewDomain.Composer(
            microServices: .init(
                getNavigation: { select, notify, completion in
                       
                    switch select {
                    case .showcase:
                        let composer = CollateralLoanLandingComposer()
                        let picker = composer.compose()
                        completion(.showcase(picker))
                    }
                }),
            scheduler: .main,
            interactiveScheduler: .global(qos: .userInitiated))
        
        return composer.compose()
    }
}
