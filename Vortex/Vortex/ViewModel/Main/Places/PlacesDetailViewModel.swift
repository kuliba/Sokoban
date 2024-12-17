//
//  PlacesDetailViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 05.04.2022.
//

import Foundation
import SwiftUI
import CoreLocation
import UIKit

struct PlacesDetailViewModel: Identifiable {
    
    let id: AtmData.ID
    let icon: Image
    let name: String
    let address: String
    let metro: MetroViewModel?
    let distance: String?
    let routeButton: RouteButtonViewModel?
    let schedule: String
    let phoneNumber: String
    let email: String
    let services: ServicesViewModel?
    
    internal init(id: String, icon: Image, name: String, address: String, metro: MetroViewModel?, distance: String?, routeButton: RouteButtonViewModel?, schedule: String, phoneNumber: String, email: String, services: ServicesViewModel?) {
        
        self.id = id
        self.icon = icon
        self.name = name
        self.address = address
        self.metro = metro
        self.distance = distance
        self.routeButton = routeButton
        self.schedule = schedule
        self.phoneNumber = phoneNumber
        self.email = email
        self.services = services
    }
    
    init(atmItem: AtmData, metroStations: [AtmMetroStationData]? , services: [AtmServiceData]?, currentLocation: CLLocationCoordinate2D?) {

        self.init(id: atmItem.id,
                  icon: Image(atmItem.iconName),
                  name: atmItem.name,
                  address: atmItem.address,
                  metro: .init(stationsData: metroStations),
                  distance: atmItem.distanceFormatted(to: currentLocation),
                  routeButton: Self.routeButtonViewModel(start: currentLocation, dest: atmItem.coordinate),
                  schedule: atmItem.schedule,
                  phoneNumber: atmItem.phoneNumber,
                  email: atmItem.email,
                  services: .init(servicesData: services))
    }
    
    static func routeButtonViewModel(start: CLLocationCoordinate2D?, dest: CLLocationCoordinate2D?) -> RouteButtonViewModel? {
    
        guard let start = start, let dest = dest else {
            return nil
        }
        
        guard let routeURL = URL(string: "maps://?saddr=\(start.latitude),\(start.longitude)&daddr=\(dest.latitude),\(dest.longitude)") else {
            return nil
        }
        
        guard UIApplication.shared.canOpenURL(routeURL) else {
            return nil
        }
        
        return RouteButtonViewModel(action: {  UIApplication.shared.open(routeURL, options: [:], completionHandler: nil)})
    }
}

//MARK: - Types

extension PlacesDetailViewModel {
    
    struct MetroViewModel {

        let stations: [StationViewModel]
        
        internal init(stations: [StationViewModel]) {
            
            self.stations = stations
        }
        
        init?(stationsData: [AtmMetroStationData]?) {
            
            guard let stationsData = stationsData else {
                return nil
            }

            self.stations = stationsData.map{ StationViewModel(id: $0.id, name: $0.name, color: $0.color.color) }
        }
        
        struct StationViewModel: Identifiable, Hashable {
            
            let id: Int
            let name: String
            let color: Color
        }
    }
    
    struct RouteButtonViewModel {
        
        let title: String = "Проложить маршрут"
        let action: () -> Void
    }
    
    struct ServicesViewModel {

        let title = "Услуги"
        let services: [ServiceViewModel]
        
        internal init(services: [ServiceViewModel]) {
            
            self.services = services
        }
        
        init?(servicesData: [AtmServiceData]?) {
            
            guard let servicesData = servicesData else {
                return nil
            }
            
            self.services = servicesData.map{ ServiceViewModel(id: $0.id, name: $0.name) }
        }
        
        struct ServiceViewModel: Identifiable {
            
            let id: Int
            let name: String
        }
    }
}

//MARK: - Sample Data

extension PlacesDetailViewModel {
    
    static let sample = PlacesDetailViewModel(id: UUID().uuidString, icon: .ic48PinOffice, name: "Рублевский (офис)", address: "г. Москва, Рублевское ш., дом 62, ТЦ «ЕвроПарк»", metro: .init(stations: [.init(id: 1, name: "Крылатское", color: Color(hex: "#3377B9")), .init(id: 2, name: "Крылатское", color: Color(hex: "#3377B9")), .init(id: 3, name: "Крылатское", color: Color(hex: "#3377B9"))]), distance: "128 M", routeButton: .init(action: {}), schedule: "Ежедневно: 10:00 - 21:45", phoneNumber: "(495) 204 4612", email: "rumyantsevo@forabank.ru", services: .init(services: [.init(id: 1, name: "Без выходных"), .init(id: 2, name: "Вклады"), .init(id: 3, name: "Потреб. кредиты"), .init(id: 4, name: "Ипотека"), .init(id: 5, name: "Выдача наличных"), .init(id: 6, name: "Прием наличных"), .init(id: 7, name: "Денежные переводы"), .init(id: 8, name: "Оплата услуг"), .init(id: 9, name: "Аккредитивы"), .init(id: 10, name: "регистрация в ЕБС"), .init(id: 11, name: "Обслуживание юридических лиц")]))
}
