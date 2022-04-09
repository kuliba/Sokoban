//
//  PlacesViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 30.03.2022.
//

import Foundation
import SwiftUI
import Combine
import MapKit

class PlacesViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()

    let title = "Отделения и банкоматы"
    @Published var control: PlacesControlViewModel
    @Published var map: PlacesMapViewModel
    @Published var list: PlacesListViewModel?
    @Published var filter: AtmFilter?
    @Published var modal: Modal?
    
    private let model: Model
    private let atmList: [AtmData]
    private let atmMetroStations: [AtmMetroStationData]?
    private let atmServices: [AtmServiceData]?
    private var bindings = Set<AnyCancellable>()

    init(control: PlacesControlViewModel, mapViewModel: PlacesMapViewModel = .emptyMock, listViewModel: PlacesListViewModel? = nil, filter: AtmFilter? = nil, atmList: [AtmData] = [], atmMetroStations: [AtmMetroStationData]? = nil, atmServices: [AtmServiceData]? = nil, model: Model = .emptyMock) {
        
        self.control = control
        self.map = mapViewModel
        self.list = listViewModel
        self.filter = filter
        self.modal = nil
        self.atmList = atmList
        self.atmMetroStations = atmMetroStations
        self.atmServices = atmServices
        self.model = model
    }
    
    init?(_ model: Model) {
        
        guard let atmList = model.dictionaryAtmList() else {
            return nil
        }
        
        
        self.control = PlacesControlViewModel(mode: .map)
    
        //TODO: load from settings
        let filter: AtmFilter? = nil
        let filterredAtmList = Self.filterred(atmList: atmList, filter: filter)
        self.map = PlacesMapViewModel(with: filterredAtmList, initialRegion: Self.initialRegion)
        
        self.atmList = atmList
        self.atmMetroStations = model.dictionaryAtmMetroStations()
        self.atmServices = model.dictionaryAtmServices()
        self.model = model
        
        bind()
    }
    
    private func bind() {
    
        map.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PlacesMapViewModelAction.ItemDidSelected:
                    guard let atmItem = atmList.first(where: { $0.id == payload.itemId }) else {
                              return
                          }
                    
                    let detailViewModel = PlacesDetailViewModel(atmItem: atmItem, metroStations: metroStations(for: atmItem), services: services(for: atmItem), currentLocation: nil, routeAction: { print("Make route...")})
                    modal = .detail(detailViewModel)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        control.$mode
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] mode in
                
                switch mode {
                case .list:
                    
                    let filterredAtmList = Self.filterred(atmList: atmList, filter: filter)
                    let listViewModel = PlacesListViewModel(atmList: filterredAtmList, metroStationsList: atmMetroStations, filter: .sample)
                    
                    withAnimation {
                        self.list = listViewModel
                    }
                    bind(listViewModel: listViewModel)
                    
                case .map:
                    withAnimation {
                        self.list = nil
                    }
                }
                
            }.store(in: &bindings)
        
        control.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PlacesControlViewModelAction.FilterDidTapped:
                    guard let atmServices = atmServices else {
                        return
                    }

                    let filterViewModel = PlacesFilterViewModel(atmCategories: AtmData.Category.allCases, atmServices: atmServices, filter: filter)
                    modal = .filter(filterViewModel)
                    bind(filterViewModel: filterViewModel)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        $filter
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] filter in
                
                let filterredAtmList = Self.filterred(atmList: atmList, filter: filter)
                map.update(with: filterredAtmList)
                list?.update(with: filterredAtmList, metroStationsList: atmMetroStations, filter: .sample)
                
            }.store(in: &bindings)
    }
    
    private func bind(listViewModel: PlacesListViewModel) {
        
        listViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PlacesListViewModelAction.ItemDidSelected:
                    guard let atmItemCoordinate = atmList.first(where: { $0.id == payload.itemId })?.coordinate else {
                              return
                          }
                    
                    let region = MKCoordinateRegion(center: atmItemCoordinate, span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001))
                    map.action.send(PlacesMapViewModelAction.ShowRegion(region: region))
                    control.action.send(PlacesControlViewModelAction.ToggleMode())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(filterViewModel: PlacesFilterViewModel) {
        
        filterViewModel.$filter
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] filter in
                
                self.filter = filter
                
            }.store(in: &bindings)
    }
    
    func metroStations(for atm: AtmData) -> [AtmMetroStationData]? {
        
        guard let atmMetroStations = atmMetroStations else {
            return nil
        }
        
        return atmMetroStations.filter{ atm.metroStationList.contains($0.id) }
    }
    
    func services(for atm: AtmData) -> [AtmServiceData]? {
        
        guard let atmServices = atmServices else {
            return nil
        }
        
        return atmServices.filter{ atm.serviceIdList.contains($0.id) }
    }
    
    static func filterred(atmList: [AtmData], filter: AtmFilter?) -> [AtmData] {
        
        guard let filter = filter else {
            return atmList
        }
 
        return atmList.filter({ filter.types.contains($0.type) }).filter({ filter.services.isSuperset(of: $0.serviceIdList)})
    }
    
    static var initialRegion: MKCoordinateRegion {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        return MKCoordinateRegion(center: .moscow, span: span)
    }
}

//MARK: - Types

extension PlacesViewModel {
    
    struct Filter {
        
        struct Distance {
            
            let location: CLLocationCoordinate2D
            let radius: CLLocationDistance
            
            var radiusTitle: String {
                
                NumberFormatter.distance.string(fromMeters: radius)
            }
            
            static let sample = Distance(location: .moscow, radius: 5000)
        }
    }
    
    enum Modal: Identifiable {
        
        case detail(PlacesDetailViewModel)
        case filter(PlacesFilterViewModel)
        
        var id: String {
            
            switch self {
            case .detail(let placesDetailViewModel): return placesDetailViewModel.id
            case .filter(let placesFilterViewModel): return placesFilterViewModel.id
            }
        }
    }
}
