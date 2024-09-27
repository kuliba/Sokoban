//
//  ComposedCategoryPickerSectionFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import PayHubUI
import RxViewModel
import SwiftUI
import UIPrimitives

struct ComposedCategoryPickerSectionFlowView<CategoryPickerItemLabel, DestinationView>: View
where CategoryPickerItemLabel: View,
      DestinationView: View {
    
    let binder: CategoryPickerSection.Binder
    let config: Config
    let itemLabel: (CategoryPickerSectionState.Item) -> CategoryPickerItemLabel
    let makeDestinationView: MakeDestinationView
    
    var body: some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                CategoryPickerSectionFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeAlert: makeAlert,
                        makeContentView: makeContentView,
                        makeDestinationView: makeDestinationView
                    )
                )
            }
        )
    }
}

extension ComposedCategoryPickerSectionFlowView {
    
    typealias MakeDestinationView = (CategoryPickerSection.Destination) -> DestinationView
    typealias Config = CategoryPickerSectionContentViewConfig
}

private extension ComposedCategoryPickerSectionFlowView {
    
    func makeAlert(
        failure: SelectedCategoryFailure
    ) -> Alert {
        
        return .init(
            with: .error(message: failure.message, event: .dismiss),
            event: { binder.flow.event($0) }
        )
    }
    
    func makeContentView() -> some View {
        
        CategoryPickerSectionContentWrapperView(
            model: binder.content,
            makeContentView: { state, event in
                
                CategoryPickerSectionContentView(
                    state: state,
                    event: event,
                    config: config,
                    itemLabel: itemLabel
                )
            }
        )
    }
}

extension AlertModelOf<CategoryPickerSection.FlowEvent> {
    
    private static func `default`(
        title: String,
        message: String?,
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent? = nil
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: primaryEvent
            ),
            secondaryButton: secondaryEvent.map {
                
                .init(
                    type: .cancel,
                    title: "Отмена",
                    event: $0
                )
            }
        )
    }
    
    static func error(
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: message != .errorRequestLimitExceeded ? "Ошибка" : "",
            message: message,
            primaryEvent: event
        )
    }
    
}
