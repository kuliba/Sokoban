//
//  PaymentsTransfersCorporateContentViewFactory.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

public struct PaymentsTransfersCorporateContentViewFactory<RestrictionNoticeView> {
    
    public let makeRestrictionNoticeView: MakeRestrictionNoticeView
    
    public init(
        makeRestrictionNoticeView: @escaping MakeRestrictionNoticeView
    ) {
        self.makeRestrictionNoticeView = makeRestrictionNoticeView
    }
}

public extension PaymentsTransfersCorporateContentViewFactory {
    
    typealias MakeRestrictionNoticeView = () -> RestrictionNoticeView
}
