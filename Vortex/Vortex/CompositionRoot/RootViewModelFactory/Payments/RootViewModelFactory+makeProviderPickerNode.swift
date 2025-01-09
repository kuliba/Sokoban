//
//  RootViewModelFactory+makeProviderPickerNode.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.11.2024.
//

import Combine
import PayHub
import VortexTools

extension RootViewModelFactory {
    
    func makeProviderPickerNode(
        multi: MultiElementArray<SegmentedOperatorProvider>,
        qrCode: QRCode,
        qrMapping: QRMapping,
        notify: @escaping (SegmentedPaymentProviderPickerFlowModel.State.NotifyEvent) -> Void
    ) -> Node<SegmentedPaymentProviderPickerFlowModel> {
        
        let picker = makeSegmentedPaymentProviderPickerFlowModel(
            multi: multi,
            qrCode: qrCode,
            qrMapping: qrMapping
        )
        
        return .init(
            model: picker,
            cancellables: bind(picker, to: notify)
        )
    }
    
    // QRNavigationComposer.swift:220
    func bind(
        _ picker: SegmentedPaymentProviderPickerFlowModel,
        to notify: @escaping (SegmentedPaymentProviderPickerFlowModel.State.NotifyEvent) -> Void
    ) -> Set<AnyCancellable> {
        
        // TODO: - add observation for loading state
        //        let isLoading = picker.$state.map(\.isLoading)
        //        let isLoadingFlip = isLoading
        //            .combineLatest(isLoading.dropFirst())
        //            .filter { $0 != $1 }
        //            .map(\.0)
        //            .sink { notify(.isLoading($0)) }
        
        let outside = picker.$state
            .compactMap(\._notifyEvent)
            .sink { notify($0) }
        
        return [/*isLoadingFlip,*/ outside]
    }
}

extension SegmentedPaymentProviderPickerFlowModel.State {
    
    typealias NotifyEvent = Vortex.FlowEvent<Status.Outside, Never>
    
    var _notifyEvent: NotifyEvent? {
        
        switch status {
        case let .outside(outside):
            return .select(outside)
            
        default:
            return nil
        }
    }
}
