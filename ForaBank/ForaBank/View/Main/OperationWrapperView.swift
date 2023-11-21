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
    func setSelection(
        location: Location,
        completion: @escaping Completion
    ) {
        
        self.selection = .init(
            location: location,
            completion: { office in

                completion(office)
                self.consumeSelection(office: office)
            }
        )
    }
    
    func consumeSelection(office: Office?) {
        
        self.selection = nil
        self.selection?.completion(office)
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
    
    // MARK: inject location
    let location: Location = .init(id: "location")
    @StateObject var viewModel: NavigationFeatureViewModel
    
    typealias Completion = NavigationFeatureViewModel.Completion
    typealias SetSelection = (Location, @escaping Completion) -> Void
    
    let operationView: (@escaping SetSelection) -> OperationView
    let listView: (Location, @escaping (Office?) -> Void) -> ListView
    
    var body: some View {
        
        operationView(viewModel.setSelection)
            .sheet(item: .init(
                get: { viewModel.selection },
                set: { if $0 == nil { viewModel.reset() }})
            ) { selection in
                
                listView(selection.location, selection.completion)
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
            operationView: { setSelection in
               
                let viewModel = makeOperation(setSelection)
                
                return OperationView(
                    model: viewModel,
                    configuration: MainView.makeOperationViewConfiguration()
                )
            },
            listView: { resetState, completion  in
                
                PlacesListInternalView(
                    items: atmData.map { PlacesListViewModel.ItemViewModel(
                        id: $0.id,
                        name: $0.name,
                        address: $0.address,
                        metro: atmMetroStationData?.compactMap {
                            
                            PlacesListViewModel.ItemViewModel.MetroStationViewModel(
                                id: $0.id, name: $0.name, color: $0.color.color
                            )
                            
                        },
                        schedule: $0.schedule,
                        distance: nil
                    ) },
                    selectItem: { item in
                        
                        completion(Office(id: item.id, name: item.name))
                    }
                )
            }
        )
        
        return navView
    }
}
