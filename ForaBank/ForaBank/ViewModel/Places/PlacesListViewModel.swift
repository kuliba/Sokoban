//
//  PlacesListViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 30.03.2022.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

class PlacesListViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var items: [ItemViewModel]
    
    init(items: [ItemViewModel]) {
        
        self.items = items
    }
    
    init(atmList: [AtmData], metroStationsList: [AtmMetroStationData]?, referenceLoaction: CLLocationCoordinate2D) {
        
        self.items = []

        update(with: atmList, metroStationsList: metroStationsList, referenceLoaction: referenceLoaction)
    }
        
    static func atmItemsSorted(atmList: [AtmData], referenceLoaction: CLLocationCoordinate2D) -> [AtmData] {
        
        let atmItemsWithDistances: [(item: AtmData, distance: CLLocationDistance)] = atmList.compactMap { atmItem in
            
            guard let distance = atmItem.distance(to: referenceLoaction) else {
                return nil
            }
            
            return (atmItem, distance)
        }

        return atmItemsWithDistances.sorted(by: { $0.distance < $1.distance }).map{ $0.item }
    }
    
    func update(with atmList: [AtmData], metroStationsList: [AtmMetroStationData]?, referenceLoaction: CLLocationCoordinate2D) {
        
        let atmListSorted = Self.atmItemsSorted(atmList: atmList, referenceLoaction: referenceLoaction)
        
        var items = [ItemViewModel]()
        for atmItem in atmListSorted {
            
            let item = ItemViewModel(atmItem: atmItem, metroStationsList: metroStationsList, currentLoaction: referenceLoaction, action: { [weak self] in self?.action.send(PlacesListViewModelAction.ItemDidSelected(itemId: atmItem.id))})
            items.append(item)
        }
        
        self.items = items
    }
}

extension PlacesListViewModel {
    
    struct ItemViewModel: Identifiable {

        let id: AtmData.ID
        let name: String
        let address: String
        let metro: [MetroStationViewModel]?
        let schedule: String
        let distance: String?
        let action: () -> Void
        
        internal init(id: AtmData.ID, name: String, address: String, metro: [MetroStationViewModel]?, schedule: String, distance: String?, action: @escaping () -> Void) {
            
            self.id = id
            self.name = name
            self.address = address
            self.metro = metro
            self.schedule = schedule
            self.distance = distance
            self.action = action
        }
        
        init(atmItem: AtmData, metroStationsList: [AtmMetroStationData]?, currentLoaction: CLLocationCoordinate2D?, action: @escaping () -> Void) {
            
            let metroStations = metroStationsList?.filter({ atmItem.metroStationList.contains($0.id) }).map({ MetroStationViewModel(id: $0.id, name: $0.name, color: $0.color.color)})
            
            self.init(id: atmItem.id,
                      name: atmItem.name,
                      address: atmItem.address,
                      metro: metroStations,
                      schedule: atmItem.schedule,
                      distance: atmItem.distanceFormatted(to: currentLoaction),
                      action: action)
            
        }
        
        struct MetroStationViewModel: Identifiable, Hashable {
            
            let id: Int
            let name: String
            let color: Color
        }
    }
}

//MARK: - Action

enum PlacesListViewModelAction {
    
    struct ItemDidSelected: Action {
        
        let itemId: AtmData.ID
    }
}

//MARK: - Sample Data

extension PlacesListViewModel.ItemViewModel {
    
    static let sampleOne = PlacesListViewModel.ItemViewModel(id: UUID().uuidString, name: "Автозаводская (офис)", address: "Рублевское ш., дом 62, ТЦ «ЕвроПарк»", metro: [.init(id: 1, name: "Автозаводская", color: Color(hex: "7ABA62")), .init(id: 2, name: "Автозаводская", color: Color(hex: "7ABA62")), .init(id: 3, name: "Автозаводская", color: Color(hex: "7ABA62"))], schedule: "Открыто до 20:00", distance: "128 м", action: {})
    
    static let sampleTwo = PlacesListViewModel.ItemViewModel(id: UUID().uuidString, name: "Автозаводская (банкомат)", address: "Аминьевское шоссе, дом 6", metro: [.init(id: 1, name: "Автозаводская", color: Color(hex: "7ABA62"))], schedule: "Открыто до 20:00", distance: "434 м", action: {})
}

extension PlacesListViewModel {
    
    static let sample = PlacesListViewModel(items: [.sampleOne, .sampleTwo])
}
