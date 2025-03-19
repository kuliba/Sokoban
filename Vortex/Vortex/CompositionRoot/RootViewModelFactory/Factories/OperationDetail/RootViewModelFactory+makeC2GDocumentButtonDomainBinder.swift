//
//  RootViewModelFactory+makeC2GDocumentButtonDomainBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.03.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeC2GDocumentButtonDomainBinder(
        operationID: Int
    ) -> C2GDocumentButtonDomain.Binder {
      
        return composeBinder(content: operationID, getNavigation: getNavigation, witnesses: .empty)
    }
    
    @inlinable
    func getNavigation(
        select: C2GDocumentButtonDomain.Select,
        notify: @escaping C2GDocumentButtonDomain.Notify,
        completion: @escaping (C2GDocumentButtonDomain.Navigation) -> Void
    ) {
        switch select {
        case .tap:
            completion(.destination)
        }
    }
}
