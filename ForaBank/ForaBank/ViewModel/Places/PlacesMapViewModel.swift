//
//  PlacesMapViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 30.03.2022.
//

import Foundation
import Combine
import MapKit

class PlacesMapViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var items: [ItemViewModel]
    let initialRegion: MKCoordinateRegion
    
    init(items: [ItemViewModel], initialRegion: MKCoordinateRegion) {
        
        self.items = items
        self.initialRegion = initialRegion
    }
    
    init(with atmList: [AtmData], initialRegion: MKCoordinateRegion) {
        
        self.items = atmList.compactMap { atmItem in
            
            guard let coordinate = atmItem.coordinate else {
                return nil
            }
            
            return PlacesMapViewModel.ItemViewModel(id: atmItem.id, iconName: atmItem.iconName, coordinate: coordinate, category: atmItem.category)
        }
        
        self.initialRegion = initialRegion
    }
    
    func update(with atmList: [AtmData]) {
        
        self.items = atmList.compactMap { atmItem in
            
            guard let coordinate = atmItem.coordinate else {
                return nil
            }
            
            return PlacesMapViewModel.ItemViewModel(id: atmItem.id, iconName: atmItem.iconName, coordinate: coordinate, category: atmItem.category)
        }
    }
}

//MARK: - Types

extension PlacesMapViewModel {
    
    struct ItemViewModel: Identifiable {
        
        let id: AtmData.ID
        let iconName: String
        let coordinate: CLLocationCoordinate2D
        let category: AtmData.Category
    }
}

//MARK: - Action

enum PlacesMapViewModelAction {

    struct ItemDidSelected: Action {
        
        let itemId: AtmData.ID
    }
    
    struct ShowRegion: Action {
        
        let region: MKCoordinateRegion
    }
    
    struct ShowUserLocation: Action {
        
        let region: MKCoordinateRegion
    }
}

//MARK: - Sample Data

extension PlacesMapViewModel {
    
    static let emptyMock = PlacesMapViewModel(items: [], initialRegion: MKCoordinateRegion())
}
