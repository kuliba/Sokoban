//
//  Reducer+makeProductProfileFlowReducer.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 24.06.2024.
//

import Foundation

extension RootViewModelFactory {
    
    func makeProductProfileFlowReducer() -> ProductProfileFlowReducer {
     
        ProductProfileFlowReducer(
            alertReduce: AlertReducer(productAlertsViewModel: .default).reduce,
            bottomSheetReduce: BottomSheetReducer().reduce,
            historyReduce: HistoryReducer().reduce
        )
    }
}
