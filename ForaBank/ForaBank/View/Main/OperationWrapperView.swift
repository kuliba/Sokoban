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
    
    typealias ShowAtmList = (NavigationViewModel.NavigationState) -> Void
    typealias SelectOption = () -> Void
    
    @ObservedObject var navModel: NavigationViewModel
    let operationView: (@escaping ShowAtmList) -> OperationView
    let listView: (@escaping SelectOption) -> ListView
    
    var body: some View {
        
        operationView(navModel.navigationState(_:))
            .navigationDestination(
                item: .init(
                    get: { navModel.state },
                    set: { if $0 == nil { navModel.resetState() } }
                )
            ) { state in
                
                switch state {
                case .location:
                    listView(navModel.resetState)
                }
            }
    }
}

enum NavigationOperationViewFactory {}

extension NavigationOperationViewFactory {
    
    typealias ChangeNavigationState = BusinessLogic.ChangeNavigationState
    typealias SelectAtmOption = BusinessLogic.SelectAtmOption
    typealias MakeOperationStateViewModel = (@escaping ChangeNavigationState, @escaping SelectAtmOption) -> OperationStateViewModel
    
    static func makeNavigationOperationView(
        makeOperation: @escaping MakeOperationStateViewModel,
        atmData: [AtmData],
        atmMetroStationData: [AtmMetroStationData]?
    ) -> some View {
        
        let navView = NavigationOperationView(
            navModel: .init(),
            operationView: { showAction  in
                
                OperationView(
                    model: makeOperation(showAction, { _,_  in }),
                    configuration: MainView.configurationOperationView()
                )
            },
            listView: { resetState in
                
                PlacesListInternalView(
                    items: atmData.map { PlacesListViewModel.ItemViewModel(
                        id: $0.id,
                        name: $0.name,
                        address: $0.address,
                        metro: [],
                        schedule: $0.schedule,
                        distance: nil
                    ) },
                    selectItem: { item in
                        
                        resetState()
                    }
                )
            }
        )
        
        return navView
    }
}
