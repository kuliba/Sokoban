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

final class NavigationFeatureViewModel: ObservableObject {
    
    @Published private(set) var selection: SelectionState?
    
    typealias Completion = (Office?) -> Void
    func setSelection(location: Location, completion: @escaping Completion) {
        
        self.selection = .init(location: location, completion: completion)
    }
    
    func consumeSelection(office: Office?) {
        
        self.selection?.completion(office)
        self.selection = nil
    }
    
    func reset() {
        
        self.selection = nil
    }
    
    struct SelectionState: Hashable, Identifiable {
        
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
}

struct NavigationOperationView<OperationView: View, ListView: View>: View {
    
    @StateObject var viewModel: NavigationFeatureViewModel
    
    let operationView: (Location, @escaping (Office?) -> Void) -> OperationView
    let listView: (Location, @escaping (Office?) -> Void) -> ListView
    
    var body: some View {
        
        NavigationView {
            
            operationView(viewModel.selection?.location ?? .init(id: ""), viewModel.consumeSelection)
                .sheet(item: .init(
                    get: { viewModel.selection },
                    set: { if $0 == nil { viewModel.reset() }})
                ) { selection in
                    
                    NavigationView {
                        
                        listView(viewModel.selection?.location ?? .init(id: ""), viewModel.selection?.completion ?? { _ in })
                    }
                }
        }
    }
}

enum NavigationOperationViewFactory {}

extension NavigationOperationViewFactory {
    
    typealias SelectAtmOption = BusinessLogic.SelectOffice
    typealias MakeOperationStateViewModel = (@escaping SelectAtmOption) -> OperationStateViewModel
    
    static func makeNavigationOperationView(
        makeOperation: @escaping MakeOperationStateViewModel,
        atmData: [AtmData],
        atmMetroStationData: [AtmMetroStationData]?
    ) -> some View {
        
        let navView = NavigationOperationView(
            viewModel: .init(),
            operationView: { location, completion in
                
                RootViewModelFactory.operationView(makeBusinessLogic: makeOperation)
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
                    selectItem: { item in
                        
                        completion(Office.init(id: item.id, name: item.name))
                    }
                )
            }
        )
        
        return navView
    }
}
