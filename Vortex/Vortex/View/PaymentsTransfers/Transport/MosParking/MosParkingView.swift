//
//  MosParkingView.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.06.2023.
//

import Combine
import LoadableResourceComponent
import SwiftUI

// MARK: - View Model

extension MosParkingView {
    
    typealias ViewModel = LoadableResourceViewModel<MosParkingPickerData>
}

// MARK: View

struct MosParkingView<StateView>: View
where StateView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let stateView: (ViewModel.State) -> StateView
    
    init(
        viewModel: ViewModel,
        stateView: @escaping (ViewModel.State) -> StateView
    ) {
        self.viewModel = viewModel
        self.stateView = stateView
    }
    
    var body: some View {
        
        stateView(viewModel.state)
    }
}

struct MosParkingStateView<ErrorView>: View
where ErrorView: View {
    
    typealias State = LoadableResourceViewModel<MosParkingPickerData>.State
    
    private let state: State
    private let mapper: MosParkingPickerDataMapper
    private let errorView: (Error) -> ErrorView
    
    init(
        state: State,
        mapper: MosParkingPickerDataMapper,
        errorView: @escaping (Error) -> ErrorView
    ) {
        self.state = state
        self.mapper = mapper
        self.errorView = errorView
    }
    
    var body: some View {
        
        switch state {
        case let .error(error):
            errorView(error)
            
        case let .loaded(mosParkingPickerData):
            let viewModel = mapper.map(mosParkingPickerData)
            MosParkingPicker(viewModel: viewModel)
            
        case .loading:
            SpinnerView(viewModel: .init())
        }
    }
}

// MARK: Previews

struct MosParkingView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            mosParkingStateView(state: .error(loadingError()))
            mosParkingStateView(state: .loaded(.preview))
            mosParkingStateView(state: .loading)
            
            MosParkingView(
                viewModel: .init(
                    publisher: Just(.preview)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                ),
                stateView: {
                    MosParkingStateView(
                        state: $0,
                        mapper: DefaultMosParkingPickerDataMapper(select: { _ in }),
                        errorView: errorView(error:)
                    )
                }
            )
        }
    }
    
    private static func mosParkingStateView(
        state: MosParkingStateView.State
    ) -> some View {
        
        MosParkingStateView(
            state: state,
            mapper: DefaultMosParkingPickerDataMapper(select: { _ in }),
            errorView: errorView(error:)
        )
    }
    
    private static func errorView(error: Error) -> some View {
        
        Text(error.localizedDescription)
            .foregroundColor(.red)
            .padding()
    }
    
    private static func loadingError() -> Error {
        
        NSError(domain: "Error loading Moscow Parking Data", code: 0)
    }
}

// MARK: - Preview Content

private extension MosParkingPickerData {
    
    static let preview: Self = .init(
        state: .monthlyOne,
        options: .all,
        refillID: "56"
    )
}
