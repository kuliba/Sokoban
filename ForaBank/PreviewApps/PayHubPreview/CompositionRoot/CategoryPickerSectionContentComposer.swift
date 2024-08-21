//
//  CategoryPickerSectionContentComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import CombineSchedulers
import Foundation
import PayHubUI

final class CategoryPickerSectionContentComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

extension CategoryPickerSectionContentComposer {
    
    func compose(
        loadedCategories: [ServiceCategory]
    ) -> CategoryPickerSectionContent {
        
        let composer = LoadablePickerModelComposer(
            load: { completion in
                
                self.scheduler.schedule(
                    after: .init(.now().advanced(by: .seconds(2)))
                ) {
                    completion(loadedCategories.map { CategoryPickerSectionItem.category($0) })
                }
            },
            scheduler: scheduler
        )
        
        return composer.compose(prefix: [], suffix: [], placeholderCount: 6)
    }
}
