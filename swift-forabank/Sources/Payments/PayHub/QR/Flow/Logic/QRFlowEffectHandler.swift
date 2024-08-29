//
//  QRFlowEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public final class QRFlowEffectHandler<Destination, ScanResult> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = QRFlowEffectHandlerMicroServices<Destination, ScanResult>
}

public extension QRFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .processScanResult(scanResult):
            microServices.processScanResult(scanResult) { dispatch(.setDestination($0)) }
        }
    }
}

public extension QRFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = QRFlowEvent<Destination, ScanResult>
    typealias Effect = QRFlowEffect<ScanResult>
}
