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
    
    // var since `QRViewModel` needs a closure to initialise
    var qrModel: QRViewModel?
    
    private let handleScanResult: HandleScanResult
    
    private let stateSubject = PassthroughSubject<State?, Never>()
    private var cancellable: AnyCancellable?
    
    init(
        handleScanResult: @escaping HandleScanResult,
        makeQRModel: MakeQRModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.handleScanResult = handleScanResult
        
        let qrModel = makeQRModel { [weak self] in self?.event(.cancel) }
        let cancellable = qrModel.action
            .compactMap { $0 as? QRViewModelAction.Result }
            .map(\.result)
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.scanResult($0)) }
        
        self.qrModel = qrModel
        self.cancellable = cancellable
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension QRModelWrapper {
    
    typealias State = QRModelWrapperState<QRResult>
    typealias MakeQRModel = (@escaping () -> Void) -> QRViewModel
    typealias HandleScanResult = (QRViewModel.ScanResult, @escaping (QRResult) -> Void) -> Void
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
            handleScanResult(scanResult) { [weak self] in
                
                self?.event(.qrResult($0))
            }
        }
    }
}
