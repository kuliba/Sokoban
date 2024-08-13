//
//  QRModelWrapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class QRModelWrapper<QRResult>: ObservableObject {
    
    @Published private(set) var state: State?
    
    let qrModel: QRViewModel
    
    private let mapScanResult: MapScanResult
    
    private let stateSubject = PassthroughSubject<State?, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        mapScanResult: @escaping MapScanResult,
        makeQRModel: MakeQRModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.mapScanResult = mapScanResult
        let subject = PassthroughSubject<Void, Never>()
        self.qrModel = makeQRModel { [subject] in subject.send(()) }
        
        qrModel.action
            .compactMap { $0 as? QRViewModelAction.Result }
            .map(\.result)
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.scanResult($0)) }
            .store(in: &cancellables)
        
        subject
            .receive(on: scheduler)
            .sink { [weak self] _ in self?.event(.cancel) }
            .store(in: &cancellables)
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension QRModelWrapper {
    
    typealias State = QRModelWrapperState<QRResult>
    typealias MakeQRModel = (@escaping () -> Void) -> QRViewModel
    typealias MapScanResult = (QRViewModel.ScanResult, @escaping (QRResult) -> Void) -> Void
}

extension QRModelWrapper {
    
    typealias Event = QRModelWrapperEvent<QRResult>
    typealias Effect = QRModelWrapperEffect
    
    func event(_ event: Event) {
        
        var state = state
        let effect = reduce(&state, event)
        stateSubject.send(state)
        effect.map(handle)
    }
}

private extension QRModelWrapper {
    
    func reduce(
        _ state: inout State?,
        _ event: Event
    ) -> Effect? {
        
        var effect: Effect?
        
        switch event {
        case .cancel:
            state = .cancelled
            
        case let .qrResult(qrResult):
            state = .qrResult(qrResult)
            
        case let .scanResult(scanResult):
            state = .inflight
            effect = .scanResult(scanResult)
        }
        
        return effect
    }
    
    func handle(effect: Effect) {
        
        switch effect {
        case let .scanResult(scanResult):
            mapScanResult(scanResult) { [weak self] in
                
                self?.event(.qrResult($0))
            }
        }
    }
}
