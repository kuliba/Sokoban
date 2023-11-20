//
//  OperationWrapperView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 15.11.2023.
//

import Foundation
import PaymentSticker
import SwiftUI
import LandingUIComponent

final class NavigationViewModel: ObservableObject {
    
    @Published private(set) var state: NavigationState?
    
    init(state: NavigationState? = nil) {
        self.state = state
    }
    
    func setLocation() {
        
        navigationState(.location)
    }
    
    func navigationState(_ state: NavigationState) {
        
        self.state = state
    }
    
    func resetState() {
        
        self.state = nil
    }
    
    enum NavigationState: Hashable, Identifiable {
        
        case location
        
        var id: Self { self }
    }
}

struct NavigationOperationView<OperationView: View, ListView: View>: View {
    
    @State private var state: SelectionState?
    
    private struct SelectionState: Hashable, Identifiable {
        
        let location: Location
        let completion: (Office?) -> Void
        
        var id: Location { location }
        
        static func == (lhs: SelectionState, rhs: SelectionState) -> Bool {
            lhs.location == rhs.location
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(location)
        }
    }
    
    let operationView: () -> OperationView
    let listView: (Location, @escaping (Office?) -> Void) -> ListView
    
    var body: some View {
        
        NavigationView {
            
            operationView()
                .navigationDestination(item: $state) { state in
                    
                    listView(state.location, state.completion)
                }
        }
    }
}

enum NavigationOperationViewFactory {}

extension NavigationOperationViewFactory {
    
    typealias SelectAtmOption = PaymentSticker.BusinessLogic.SelectOffice
    typealias MakeOperationStateViewModel = (@escaping SelectAtmOption) -> OperationStateViewModel
    
    static func makeNavigationOperationView(
        makeOperation: @escaping MakeOperationStateViewModel,
        atmData: [AtmData],
        atmMetroStationData: [AtmMetroStationData]?
    ) -> some View {
        
        let navView = NavigationOperationView(
            operationView: {
                
                OperationView(
                    model: makeOperation({ location, completion in
                        
                    }),
                    configuration: MainView.makeOperationViewConfiguration()
                )
            },
            listView: { resetState, completion  in
                
                PlacesListInternalView(
                    items: atmData.map { PlacesListViewModel.ItemViewModel(
                        id: $0.id,
                        name: $0.name,
                        address: $0.address,
                        metro: [],
                        schedule: $0.schedule,
                        distance: nil
                    ) },
                    selectItem: { _ in }
                )
            }
        )
        
        return navView
    }
}
