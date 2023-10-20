//
//  ContentView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 20.10.2023.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
      
        OperationView(model: .preview)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
