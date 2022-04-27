//
//  MessagesHistoryViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.04.2022.
//

import SwiftUI
import Combine

class MessagesHistoryViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    @Published var sections: [MessagesHistorySectionView]
    
    private let model: Model
    
    init( model: Model) {
        self.model = model
        self.sections = []
    }
    
    init( sections: [MessagesHistorySectionView]) {
        self.model = Model.emptyMock
        self.sections = sections
    }
}
