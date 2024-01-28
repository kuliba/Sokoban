//
//  GenericRoute.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import Combine

public struct GenericRoute<ViewModel, Destination, Modal, Alert>
where ViewModel: ObservableObject {
    
    public let viewModel: ViewModel
    public let cancellable: AnyCancellable
    public var destination: Destination?
    public var modal: Modal?
    public var alert: Alert?
    
    public init(
        _ viewModel: ViewModel,
        _ cancellable: AnyCancellable,
        destination: Destination? = nil,
        modal: Modal? = nil,
        alert: Alert? = nil
    ) {
        self.viewModel = viewModel
        self.cancellable = cancellable
        self.destination = destination
        self.modal = modal
        self.alert = alert
    }
}

extension GenericRoute: Equatable
where Destination: Equatable,
      Modal: Equatable,
      Alert: Equatable {
    
    public static func == (_ lhs: Self, rhs: Self) -> Bool {
        
        ObjectIdentifier(lhs.viewModel) == ObjectIdentifier(rhs.viewModel)
        && lhs.destination == rhs.destination
        && lhs.modal == rhs.modal
        && lhs.alert == rhs.alert
    }
}

extension GenericRoute: Hashable
where Destination: Hashable,
      Modal: Hashable,
      Alert: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(ObjectIdentifier(viewModel))
        hasher.combine(destination)
        hasher.combine(modal)
        hasher.combine(alert)
    }
}
