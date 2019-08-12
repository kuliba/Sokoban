//
//  BankBranchView.swift
//  TestHero
//
//  Created by Sergey on 20/12/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

import UIKit
import MapKit

//class BankBranchMarkerView: MKMarkerAnnotationView {
//    //  MARK: Properties
//    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
//
//}
////  MARK: Configuration
//private extension BankBranchMarkerView {
//    func configure(with annotation: MKAnnotation) {
//        guard let a = annotation as? BankBranchAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
//        //    CONFIGURE
//        clusteringIdentifier = String(describing: BankBranchMarkerView.self)
////        markerTintColor = .purple
////        glyphImage = #imageLiteral(resourceName: "rapper")
//        markerTintColor = .red
//        glyphImage = nil
//
//        if let imageName = a.imageName {
//            print(imageName)
//            glyphImage = UIImage(named: imageName)
//        } else {
//            glyphImage = nil
//        }
//
//    }
//}

class BankBranchView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? BankBranchAnnotation else {return}
            
//            canShowCallout = true
//            calloutOffset = CGPoint(x: -5, y: 5)
//            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
//                                                    size: CGSize(width: 30, height: 30)))
//            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControlState())
//            rightCalloutAccessoryView = mapsButton
//            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            detailCalloutAccessoryView = UIButton(type: .detailDisclosure)
            clusteringIdentifier = String(describing: BankBranchView.self)
            
            canShowCallout = false
            
            if let imageName = annotation.imageName {
                image = UIImage(named: imageName)
            } else {
                image = nil
            }
            
//            let detailLabel = UILabel()
//            detailLabel.numberOfLines = 0
//            detailLabel.font = detailLabel.font.withSize(12)
//            detailLabel.text = artwork.subtitle
//            detailCalloutAccessoryView = detailLabel
        }
    }
    
}
