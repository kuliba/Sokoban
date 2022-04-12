//
//  PlacesMapView.swift
//  ForaBank
//
//  Created by Max Gribov on 30.03.2022.
//

import Foundation
import SwiftUI
import MapKit
import Combine

struct PlacesMapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: PlacesMapViewModel
    
    private let mapView = MKMapView(frame: .zero)

    func makeUIView(context: Context) -> MKMapView {

        mapView.register(PlaceAnnotationView.self, forAnnotationViewWithReuseIdentifier: PlaceAnnotationView.identifier)
        mapView.register(PlaceClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        // set initial region
        mapView.region = viewModel.initialRegion
        
        // map type
        mapView.mapType = .mutedStandard
        
        // show user location
        mapView.showsUserLocation = true

        // delegate
        mapView.delegate = context.coordinator
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel: viewModel, mapView: mapView)
    }
}

//MARK: - Coordinator

extension PlacesMapView {
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        let viewModel: PlacesMapViewModel
        let mapView: MKMapView
        
        private var bindings = Set<AnyCancellable>()
        
        init(viewModel: PlacesMapViewModel, mapView: MKMapView) {
            
            self.viewModel = viewModel
            self.mapView = mapView
            super.init()
            
            bind()
        }
     
        private func bind() {
            
            viewModel.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as PlacesMapViewModelAction.ShowRegion:
                        mapView.setRegion(payload.region, animated: true)
                        
                    case let payload as PlacesMapViewModelAction.ShowUserLocation:
                       
                        mapView.setRegion(payload.region, animated: true)
                        
                    default:
                        return
                    }
                    
                }.store(in: &bindings)
            
            viewModel.$items
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] items in
                    
                    mapView.removeAnnotations(mapView.annotations)
                    let annotations = viewModel.items.map{ PlaceAnnotation(with: $0) }
                    mapView.addAnnotations(annotations)
                    
                }.store(in: &bindings)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            guard let placeAnnotation = annotation as? PlaceAnnotation else {
                return nil
            }
            
            let placeView = mapView.dequeueReusableAnnotationView(withIdentifier: PlaceAnnotationView.identifier, for: placeAnnotation)
            placeView.clusteringIdentifier = "cluster"
            
            return placeView
        }
     
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            let annotation = view.annotation
            
            if let placeAnnotation = annotation as? PlaceAnnotation  {
                
                viewModel.action.send(PlacesMapViewModelAction.ItemDidSelected(itemId: placeAnnotation.id))
                
            } else if let clusterAnnotation = annotation as? MKClusterAnnotation {
                
                mapView.showAnnotations(clusterAnnotation.memberAnnotations, animated: true)
            }
            
            deselectAnnotations()
        }
        
        func deselectAnnotations() {
            
            for annotation in mapView.selectedAnnotations {
                
                mapView.deselectAnnotation(annotation, animated: false)
            }
        }
    }
}

//MARK: - Annotations

extension PlacesMapView {
    
    class PlaceAnnotation: NSObject, MKAnnotation {

        let id: AtmData.ID
        let coordinate: CLLocationCoordinate2D
        let iconName: String
        let category: AtmData.Category
        let title: String? = nil
        let subtitle: String? = nil
        
        init(id: AtmData.ID, coordinate: CLLocationCoordinate2D, iconName: String, category: AtmData.Category) {
            
            self.id = id
            self.coordinate = coordinate
            self.iconName = iconName
            self.category = category
        }
        
        convenience init(with itemViewModel: PlacesMapViewModel.ItemViewModel) {
            
            self.init(id: itemViewModel.id, coordinate: itemViewModel.coordinate, iconName: itemViewModel.iconName, category: itemViewModel.category)
        }
    }
    
    class PlaceAnnotationView: MKAnnotationView {
        
        static let identifier = "PlaceAnnotationView"
        
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForDisplay() {
            super.prepareForDisplay()
            
            displayPriority = .defaultLow
            
            guard let placeAnnotation = annotation as? PlaceAnnotation,
                  let iconImage = UIImage(named: placeAnnotation.iconName) else {
                      
                      return
                  }

            image = iconImage
            centerOffset = CGPoint(x: iconImage.size.width / 2, y: -(iconImage.size.height / 2) )
        }
    }
    
    class PlaceClusterAnnotationView: MKAnnotationView {
        
        let label: UILabel
        
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            
            self.label = UILabel(frame: .zero)
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            
            label.textColor = .white
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            collisionMode = .circle
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForDisplay() {
            super.prepareForDisplay()

            displayPriority = .defaultHigh
            
            guard let cluster = annotation as? MKClusterAnnotation  else {
                return
            }
            
            let categories = cluster.memberAnnotations.compactMap({ $0 as? PlaceAnnotation }).map({ $0.category })
            let imageName = categories.contains(.office) ? "ic48PinManyBranchesRed" : "ic48PinManyBranchesBlack"
            guard let iconImage = UIImage(named: imageName) else {
                      return
                  }
            image = iconImage
            centerOffset = CGPoint(x: iconImage.size.width / 2, y: -(iconImage.size.height / 2) )
            
            label.text = "\(cluster.memberAnnotations.count)"
        }
    }
}
