//
//  SberQRFeatureViewModel.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 20.11.2023.
//

import Combine
import Foundation

#warning("has the same shape as RouteModel - make RouteModel generic")
final class SberQRFeatureViewModel: ObservableObject {
    
    @Published private(set) var selection: SberQRSelection?
    
    private let selectionSubject = PassthroughSubject<SberQRSelection?, Never>()
    
    init(
        selection: SberQRSelection? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.selection = selection
        
        selectionSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .handleEvents(receiveOutput: { print($0 as Any) })
            .assign(to: &$selection)
    }
}

extension SberQRFeatureViewModel {
    
    func resetSelection() {
        
        selectionSubject.send(nil)
    }
    
    func setSelection(
        url: URL,
        completion: @escaping SberQRSelection.Completion
    ) {
        selectionSubject.send(.init(url: url, completion: completion))
    }
    
    func consumeSelection(text: String) {
        
        self.selection?.completion(text)
        resetSelection()
    }
}
