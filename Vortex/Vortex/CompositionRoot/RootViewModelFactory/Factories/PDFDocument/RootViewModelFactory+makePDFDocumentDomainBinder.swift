//
//  RootViewModelFactory+makePDFDocumentDomainBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.03.2025.
//

import Foundation
import PDFKit

extension RootViewModelFactory {
    
    @inlinable
    func makePDFDocumentDomainBinder(
        paymentOperationDetailID id: Int
    ) -> PDFDocumentDomain.Binder {
        
        let content = PDFDocumentDomain.Content.makeStateMachine(
            load: { [weak self] in self?.loadC2GPrintForm(id, $0) },
            scheduler: schedulers.main
        )
        
        return composeBinder(content: content, getNavigation: getNavigation, witnesses: .empty)
    }
    
    @inlinable
    func loadC2GPrintForm(
        _ id: Int,
        _ completion: @escaping (Result<PDFDocument, Error>) -> Void
    ) {
        getPrintForm(paymentOperationDetailID: id, printFormType: "c2g", completion: completion)
    }
    
    @inlinable
    func getNavigation(
        select: PDFDocumentDomain.Select,
        notify: @escaping PDFDocumentDomain.Notify,
        completion: @escaping (PDFDocumentDomain.Navigation) -> Void
    ) {
        switch select {
        case let .alert(message):
            completion(.alert(message))
        }
    }
}
