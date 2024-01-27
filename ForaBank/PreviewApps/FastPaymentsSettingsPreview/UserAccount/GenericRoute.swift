//
//  GenericRoute.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import Combine

struct GenericRoute<ViewModel, Destination, Modal, Alert>
where ViewModel: ObservableObject {
    
    let viewModel: ViewModel
    let cancellable: AnyCancellable
    var destination: Destination?
    var modal: Modal?
    var alert: Alert?
    
    init(
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
    
    static func == (_ lhs: Self, rhs: Self) -> Bool {
        
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(viewModel))
        hasher.combine(destination)
        hasher.combine(modal)
        hasher.combine(alert)
    }
}
