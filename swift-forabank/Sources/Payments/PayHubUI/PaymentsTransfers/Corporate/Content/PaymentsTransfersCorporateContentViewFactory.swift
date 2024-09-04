//
//  PaymentsTransfersCorporateContentViewFactory.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

public struct PaymentsTransfersCorporateContentViewFactory<BannerSectionView, RestrictionNoticeView, ToolbarView> {
    
    public let makeBannerSectionView: MakeBannerSectionView
    public let makeRestrictionNoticeView: MakeRestrictionNoticeView
    public let makeToolbarView: MakeToolbarView
    
    public init(
        makeBannerSectionView: @escaping MakeBannerSectionView,
        makeRestrictionNoticeView: @escaping MakeRestrictionNoticeView,
        makeToolbarView: @escaping MakeToolbarView
    ) {
        self.makeBannerSectionView = makeBannerSectionView
        self.makeRestrictionNoticeView = makeRestrictionNoticeView
        self.makeToolbarView = makeToolbarView
    }
}

public extension PaymentsTransfersCorporateContentViewFactory {
    
    typealias MakeBannerSectionView = () -> BannerSectionView
    typealias MakeRestrictionNoticeView = () -> RestrictionNoticeView
    typealias MakeToolbarView = () -> ToolbarView
}
