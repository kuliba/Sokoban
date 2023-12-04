//
//  SberQRFeatureViewModel.swift
//  
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Combine
import Foundation

final class SberQRFeatureViewModel: ObservableObject {
    
    typealias GetSberQRDataResult = Result<GetSberQRDataResponse, ScenarioQRError>
    typealias GetSberQRData = (QRLink, @escaping (GetSberQRDataResult) -> Void) -> Void
    
    @Published private(set) var state: SberQRFeatureState
    
    private let stateSubject = PassthroughSubject<SberQRFeatureState, Never>()
    private let getSberQRData: GetSberQRData
    
    init(
        initialState: SberQRFeatureState = .loading,
        getSberQRData: @escaping GetSberQRData,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.getSberQRData = getSberQRData
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    func loadSberQRData(url: URL) {
        
        let payload = QRLink(qrLinkString: url.absoluteString)
        
        getSberQRData(payload) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                stateSubject.send(.init(error: error))
                
            case let .success(dto):
                stateSubject.send(.getSberQRDataResponse(dto))
            }
        }
    }
    
    enum ScenarioQRError: Error {
        
        case server(statusCode: Int, errorMessage: String)
        case other(statusCode: Int, data: Data)
    }
}

private extension SberQRFeatureState {
    
    init(error: SberQRFeatureViewModel.ScenarioQRError) {
        
        switch error {
        case let .other(statusCode, data):
            self = .getSberQRDataError(.invalid(statusCode: statusCode, data: data))
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .getSberQRDataError(.server(statusCode: statusCode, errorMessage: errorMessage))
        }
    }
}
