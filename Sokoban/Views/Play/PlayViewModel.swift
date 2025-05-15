//
//  PlayViewModel.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 07.05.2025.
//

import Foundation

@MainActor
final class PlayViewModel: ObservableObject {
//    @Published var fileNames: [String] = []
    
    private let resources: ResourcesProtocol
    
    init() {
        self.resources = Resources.shared
        test()
    }
    
    func test() {
        
        Task {
            let collections = await resources.collections
            print(collections)
        }
    }
}
