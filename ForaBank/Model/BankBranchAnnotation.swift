//
//  BankBranchAnnotation.swift
//  TestHero
//
//  Created by Sergey on 20/12/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

import UIKit
import MapKit
//import Contacts

class BankBranchAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var type: String?

    init(coordinate: CLLocationCoordinate2D, type: String?) {
        self.coordinate = coordinate
        self.type = type
    }
    
    var imageName: String? {
        switch type {
        case "Банкомат":
            return "atm_annotation"
        case "Платёжный терминал":
            return "atm_annotation"
        default:
            return "bank_branch_annotation"
        }
    }
    // Annotation right callout accessory opens this mapItem in Maps app
//    func mapItem() -> MKMapItem {
//        let addressDict = [CNPostalAddressStreetKey: subtitle!]
//        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = title
//        return mapItem
//    }
}
