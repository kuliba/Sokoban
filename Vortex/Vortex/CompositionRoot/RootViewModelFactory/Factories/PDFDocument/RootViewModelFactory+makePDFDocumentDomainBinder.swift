//
//  RootViewModelFactory+makePDFDocumentDomainBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.03.2025.
//

import Foundation
import PDFKit
import StateMachines

extension RootViewModelFactory {
    
    @inlinable
    func makePDFDocumentDomainBinder(
        paymentOperationDetailID id: Int
    ) -> PDFDocumentDomain.Binder {
        
        let content = PDFDocumentDomain.Content.makeStateMachine(
            load: { [weak self] in self?.loadC2GPrintForm(id, $0) },
            scheduler: schedulers.main
        )
        
        return composeBinder(
            content: content,
            getNavigation: getNavigation,
            witnesses: .init(
                emitting: {
                    
                    $0.$state
                        .compactMap(\.failure)
                        .map { _ in .select(.alert(String.errorMessage)) }
                },
                dismissing: { _ in {}}
            )
        )
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

// MARK: - Adapters

private extension StateMachines.LoadState {
    
    var failure: Failure? {
        
        guard case let .failure(failure) = self else { return nil }
        
        return failure
    }
}

private extension String {
    
    static let errorMessage = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
}
