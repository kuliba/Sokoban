//
//  PlacesView.swift
//  ForaBank
//
//  Created by Max Gribov on 30.03.2022.
//

import SwiftUI

struct PlacesView: View {
    
    @ObservedObject var viewModel: PlacesViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                PlacesMapView(viewModel: viewModel.map)
                    .edgesIgnoringSafeArea(.all)
                
                if let listViewModel = viewModel.list {
                    
                    PlacesListView(viewModel: listViewModel)
                        .transition(.opacity)
                }
                
                PlacesControlView(viewModel: viewModel.control)
                    .frame(height: 60)
            }
            .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
            
        }
        .sheet(item: $viewModel.modal, content: { item in
            
            switch item {
            case .detail(let placesDetailViewModel):
                PlacesDetailView(viewModel: placesDetailViewModel)
                
            case .filter(let placesFilterViewModel):
                PlacesFilterView(viewModel: placesFilterViewModel)
            }
        })
        .onAppear {
            
            viewModel.action.send(PlacesViewModelAction.ViewDidLoad())
        }
    }
}

struct PlacesView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PlacesView(viewModel: .sample)
    }
}

//MARK: - Sample Data

extension PlacesViewModel {
    
    static let sample = PlacesViewModel(control: .init(mode: .map))
}
