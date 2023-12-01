//
//  ContentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var routeModel: RouteModel
    
    private let composer: Composer
    
    init(route: Route = .empty) {
        
        let composer = Composer(route: route)
        self.composer = composer
        self.routeModel = composer.routeModel
    }
    
    var body: some View {
        
        composer.makeMainView()
            .alert(
                item: routeModel.alertBinding,
                content: composer.makeAlertView
            )
            .fullScreenCover(
                item: routeModel.fullScreenCoverBinding,
                content: composer.makeFullScreenCoverView
            )
            .navigationDestination(
                item: routeModel.destinationBinding,
                content: composer.makeDestinationView
            )
            .sheet(
                item: routeModel.sheetBinding,
                content: composer.makeSheet
            )
    }
}

private extension RouteModel {
    
    var destinationBinding: Binding<Route.Destination?> {
        
        .init(
            get: { [weak self] in self?.route.destination },
            set: { [weak self] in
                
                if $0 == nil { self?.resetDestination() }
            }
        )
    }
    
    var alertBinding: Binding<Route.Modal.Alert?> {
        
        .init(
            get: { [weak self] in self?.route.alert },
            set: { [weak self] in
                
                if $0 == nil { self?.resetAlert() }
            }
        )
    }
    
    var fullScreenCoverBinding: Binding<Route.Modal.FullScreenCover?> {
        
        .init(
            get: { [weak self] in self?.route.fullScreenCover },
            set: { [weak self] in
                
                if $0 == nil { self?.resetFullScreenCover() }
            }
        )
    }
    
    var sheetBinding: Binding<Route.Modal.Sheet?> {
        
        .init(
            get: { [weak self] in self?.route.sheet },
            set: { [weak self] in
                
                if $0 == nil { self?.resetSheet() }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
