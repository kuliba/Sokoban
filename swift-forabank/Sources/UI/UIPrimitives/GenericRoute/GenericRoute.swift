//
//  GenericRoute.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Combine
import Foundation

public struct GenericRoute<ViewModel, Destination, Modal, Alert> : Identifiable
where ViewModel: ObservableObject  {
    
    public let id: UUID = UUID()
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
