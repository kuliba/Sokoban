//
//  FilterEffectMicroServicesComposer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 19.09.2024.
//

import Foundation
import CalendarUI

final class FilterEffectHandlerMicroServicesComposer {
    
    typealias MicroServices = FilterModelEffectHandlerMicroServices
    
    func compose() -> MicroServices {
        
        .init(updateFilter: updateFilter)
    }
}

private extension FilterEffectHandlerMicroServicesComposer {
    
    func updateFilter(
        payload: Range<Date>,
        completion: @escaping (FilterState) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            let state = FilterState(
                productId: 0,
                calendar: .init(
                    date: nil,
                    range: nil,
                    monthsData: [],
                    periods: []
                ),
                filter: .init(
                    title: "",
                    selectDates: nil,
                    periods: [.week],
                    transactionType: [.credit],
                    services: ["Папе", "Маме"]
                )
            )
            
            completion(state)
        }
    }
}
