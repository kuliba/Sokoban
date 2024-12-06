//
//  OperationWrapperView.swift
//  Vortex
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
    
    let location: Location
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
