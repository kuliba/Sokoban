//
//  RootViewModelFactory+makeDocumentButton.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import CombineSchedulers
import Foundation
import PDFKit
import RxViewModel

extension RootViewModelFactory {
    
    @inlinable
    func makeDocumentButton(
        load: @escaping (@escaping (Result<PDFDocument, Error>) -> Void) -> Void
    ) -> DocumentButtonDomain.Model {
        
        return DocumentButtonDomain.Model.makeStateMachine(
            load: load,
            scheduler: schedulers.main
        )
    }
}

