//
//  Reducer+makeProductProfileFlowReducer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 24.06.2024.
//

import Foundation

extension RootViewModelFactory {
    
    static func makeProductProfileFlowReducer() -> ProductProfileFlowReducer {
     
        ProductProfileFlowReducer(
            alertReduce: AlertReducer(productAlertsViewModel: .default).reduce,
            bottomSheetReduce: BottomSheetReducer().reduce,
            historyReduce: HistoryReducer().reduce
        )
    }
    
    static func makeControlPanelFlowReducer() -> ControlPanelFlowReducer {
     
        ControlPanelFlowReducer(
            alertReduce: ControlPanelAlertReducer(productAlertsViewModel: .default).reduce
        )
    }
}
