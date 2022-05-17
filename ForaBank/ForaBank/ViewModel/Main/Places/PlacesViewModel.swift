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
    @Published var filter: AtmFilter
    @Published var modal: Modal?
    
    private let model: Model
    private let atmList: [AtmData]
    private let atmMetroStations: [AtmMetroStationData]?
    private let atmServices: [AtmServiceData]?
    private var referenceLocation: ReferenceLocation
    private var bindings = Set<AnyCancellable>()

    init(control: PlacesControlViewModel, mapViewModel: PlacesMapViewModel = .emptyMock, listViewModel: PlacesListViewModel? = nil, filter: AtmFilter = .initial, atmList: [AtmData] = [], atmMetroStations: [AtmMetroStationData]? = nil, atmServices: [AtmServiceData]? = nil, model: Model = .emptyMock, referenceLocation: ReferenceLocation = .user(.init(latitude: 0, longitude: 0))) {
        
        self.control = control
        self.map = mapViewModel
        self.list = listViewModel
        self.filter = filter
        self.modal = nil
        self.atmList = atmList
        self.atmMetroStations = atmMetroStations
        self.atmServices = atmServices
        self.model = model
        self.referenceLocation = referenceLocation
    }
    
    init?(_ model: Model) {
        
        guard let atmList = model.dictionaryAtmList() else {
            return nil
        }
        
        
        self.control = PlacesControlViewModel(mode: .map)
    
        //TODO: load from settings
        let filter: AtmFilter = .initial
        let filterredAtmList = Self.filterred(atmList: atmList, filter: filter)
        let initialRegion = Self.initialRegion
        self.map = PlacesMapViewModel(with: filterredAtmList, initialRegion: initialRegion)
        self.referenceLocation = .map(initialRegion)
        
        self.filter = filter
        self.atmList = atmList
        self.atmMetroStations = model.dictionaryAtmMetroStations()
        self.atmServices = model.dictionaryAtmServices()
        self.model = model
        
        bind() 
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PlacesViewModelAction.ViewDidLoad:
                    model.action.send(ModelAction.Location.Updates.Start())

                default:
                    break
                }
                
            }.store(in: &bindings)
    
        map.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PlacesMapViewModelAction.ItemDidSelected:
                    guard let atmItem = atmList.first(where: { $0.id == payload.itemId }) else {
                              return
                          }
                    
                    let detailViewModel = PlacesDetailViewModel(atmItem: atmItem, metroStations: metroStations(for: atmItem), services: services(for: atmItem), currentLocation: referenceLocation.coordinate)
                    modal = .detail(detailViewModel)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        map.$currentRegion
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currentRegion in
                
                guard model.currentUserLoaction.value == nil else {
                    return
                }
                
                referenceLocation = .map(currentRegion)
                
            }.store(in: &bindings)
        
        model.currentUserLoaction
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] location in
                
                if let location = location {
                    
                    guard case .map = referenceLocation else {
                        return
                    }

                    let region = MKCoordinateRegion(center: location.coordinate, span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
                    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(200)) {
                        
                        self.map.action.send(PlacesMapViewModelAction.ShowRegion(region: region))
                    }
                    
                    referenceLocation = .user(location)
                    
                } else {
                    
                    referenceLocation = .map(map.currentRegion)
                }

            }.store(in: &bindings)
        
        control.$mode
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] mode in
                
                switch mode {
                case .list:
                    
                    let filterredAtmList = Self.filterred(atmList: atmList, filter: filter)
                    let listViewModel = PlacesListViewModel(atmList: filterredAtmList, metroStationsList: atmMetroStations, referenceLoaction: referenceLocation.coordinate)
                    
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

                    let availableServices = servicesIds(for: AtmData.Category.allCases, in: atmList)
                    let filterViewModel = PlacesFilterViewModel(atmCategories: AtmData.Category.allCases, atmServices: atmServices, atmAvailableServices: availableServices, filter: filter)
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
                list?.update(with: filterredAtmList, metroStationsList: atmMetroStations, referenceLoaction: referenceLocation.coordinate)
                
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
    
    func servicesIds(for categories: [AtmData.Category], in atmList: [AtmData]) -> [AtmData.Category: Set<AtmServiceData.ID>] {
        
        var result = [AtmData.Category: Set<AtmServiceData.ID>]()
        
        for category in categories {
            
            result[category] = Set(atmList.filter({ $0.category == category }).flatMap({ $0.serviceIdList }))
        }
    
        return result
    }
    
    static func filterred(atmList: [AtmData], filter: AtmFilter?) -> [AtmData] {
        
        guard let filter = filter else {
            return atmList
        }
 
        return atmList.filter({ filter.types.contains($0.type) }).filter { atmData in
            
            // if no services selected in filter return all atm data
            guard filter.services.count > 0 else {
                return true
            }
            
            for serviceId in atmData.serviceIdList {
                
                if filter.services.contains(serviceId) {
                    return true
                }
            }
            
            return false
        }
    }
    
    static var initialRegion: MKCoordinateRegion {
        
        //ATM: region: MKCoordinateRegion(center: __C.CLLocationCoordinate2D(latitude: 55.26070129039655, longitude: 51.392643336781866), span: __C.MKCoordinateSpan(latitudeDelta: 33.52516423737643, longitudeDelta: 32.484028468055385))
        
        let center = CLLocationCoordinate2D(latitude: 55.26070129039655, longitude: 51.392643336781866)
        let span = MKCoordinateSpan(latitudeDelta: 33.52516423737643, longitudeDelta: 32.484028468055385)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    deinit {
        
        model.action.send(ModelAction.Location.Updates.Stop())
    }
}

//MARK: - Types

extension PlacesViewModel {
    
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
    
    enum ReferenceLocation {
        
        case user(LocationData)
        case map(MKCoordinateRegion)
        
        var coordinate: CLLocationCoordinate2D {
            
            switch self {
            case .user(let locationData):
                return locationData.coordinate

            case .map(let mKCoordinateRegion):
                return mKCoordinateRegion.center
            }
        }
    }
}


//MARK: - Action

enum PlacesViewModelAction {

    struct ViewDidLoad: Action {}
}
