//
//  ContentView.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.05.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PlayView(viewModel: .init())
    }
}

#Preview {
    ContentView()
}
