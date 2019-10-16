//
//  BankBranchClusterView.swift
//  TestHero
//
//  Created by Sergey on 20/12/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

import UIKit
import MapKit

class BankBranchClusterView: MKAnnotationView {
    //  MARK: Properties
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
    //  MARK: Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
//        centerOffset = CGPoint(x: 0.0, y: -10.0)
//        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        detailCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        canShowCallout = true
//        callout
        canShowCallout = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented.")
    }
}
//  MARK: Configuration
private extension BankBranchClusterView {
    func configure(with annotation: MKAnnotation) {
        guard let annotation = annotation as? MKClusterAnnotation else { return }
        //    CONFIGURE
        
        canShowCallout = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30.0, height: 30.0))
        let count = annotation.memberAnnotations.count
        image = renderer.image { _ in
            UIColor.red.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)).fill()
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                              NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15.0)]
            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 15 - size.width / 2, y: 15 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
}
