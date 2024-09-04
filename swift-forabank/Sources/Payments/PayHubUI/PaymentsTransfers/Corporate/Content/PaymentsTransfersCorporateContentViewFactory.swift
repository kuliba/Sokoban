//
//  PaymentsTransfersCorporateContentViewFactory.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

public struct PaymentsTransfersCorporateContentViewFactory<RestrictionNoticeView, ToolbarView> {
    
    public let makeRestrictionNoticeView: MakeRestrictionNoticeView
    public let makeToolbarView: MakeToolbarView
    
    public init(
        makeRestrictionNoticeView: @escaping MakeRestrictionNoticeView,
        makeToolbarView: @escaping MakeToolbarView
    ) {
        self.makeRestrictionNoticeView = makeRestrictionNoticeView
        self.makeToolbarView = makeToolbarView
    }
}

public extension PaymentsTransfersCorporateContentViewFactory {
    
    typealias MakeRestrictionNoticeView = () -> RestrictionNoticeView
    typealias MakeToolbarView = () -> ToolbarView
}
