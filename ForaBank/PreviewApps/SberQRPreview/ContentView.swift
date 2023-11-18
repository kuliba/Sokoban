//
//  ContentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var navigationModel: NavigationModel
    private let composer: Composer
    
    init(navigation: Navigation? = nil) {
        
        let composer = Composer(navigation: navigation)
        self.composer = composer
        self.navigationModel = composer.navigationModel
    }
    
    var body: some View {
        
        composer.makeMainView()
            .alert(
                item: navigationModel.alertBinding,
                content: composer.makeAlertView
            )
            .fullScreenCover(
                item: navigationModel.fullScreenCoverBinding,
                content: composer.makeFullScreenCoverView
            )
            .navigationDestination(
                item: navigationModel.destinationBinding,
                content: composer.makeDestinationView
            )
            .sheet(
                item: navigationModel.sheetBinding,
                content: composer.makeSheet
            )
    }
}

private extension NavigationModel {
    
    var alertBinding: Binding<Navigation.Alert?> {
        
        .init(
            get: { [weak self] in self?.navigation?.alert },
            set: { [weak self] in
                
                if $0 == nil { self?.resetAlert() }
            }
        )
    }
    
    var destinationBinding: Binding<Navigation.Destination?> {
        
        .init(
            get: { [weak self] in self?.navigation?.destination },
            set: { [weak self] in
                
                if $0 == nil { self?.resetDestination() }
            }
        )
    }
    
    var fullScreenCoverBinding: Binding<Navigation.FullScreenCover?> {
        
        .init(
            get: { [weak self] in self?.navigation?.fullScreenCover },
            set: { [weak self] in
                
                if $0 == nil { self?.resetFullScreenCover() }
            }
        )
    }
    
    var sheetBinding: Binding<Navigation.Sheet?> {
        
        .init(
            get: { [weak self] in self?.navigation?.sheet },
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
