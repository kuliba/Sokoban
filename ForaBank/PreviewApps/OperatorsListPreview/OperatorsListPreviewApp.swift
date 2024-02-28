//
//  OperatorsListPreviewApp.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import SwiftUI
import SearchBarComponent
import TextFieldUI
import TextFieldComponent

@main
struct OperatorsListPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            
            NavigationView {
                
                ContentView(
                    searchViewModel: .init(
                            initialState: .placeholder("Search subscriptions"),
                            reducer: TransformingReducer(
                                placeholderText: "Search subscriptions"
                            ),
                    keyboardType: .decimal
                ))
                .navigationBarTitle(Text("Услуги ЖКХ"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {}, label: {
                    
                    Image.init(systemName: "photo.artframe")
                }))
            }
        }
    }
}
