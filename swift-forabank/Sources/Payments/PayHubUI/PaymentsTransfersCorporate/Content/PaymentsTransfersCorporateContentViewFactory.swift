//
//  PaymentsTransfersCorporateContentViewFactory.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

public struct PaymentsTransfersCorporateContentViewFactory<BannerPicker, BannerSectionView, RestrictionNoticeView, ToolbarView, TransfersSectionView> {
    
    public let makeBannerSectionView: MakeBannerSectionView
    public let makeRestrictionNoticeView: MakeRestrictionNoticeView
    public let makeToolbarView: MakeToolbarView
    public let makeTransfersSectionView: MakeTransfersSectionView
    
    public init(
        makeBannerSectionView: @escaping MakeBannerSectionView,
        makeRestrictionNoticeView: @escaping MakeRestrictionNoticeView,
        makeToolbarView: @escaping MakeToolbarView,
        makeTransfersSectionView: @escaping MakeTransfersSectionView
    ) {
        self.makeBannerSectionView = makeBannerSectionView
        self.makeRestrictionNoticeView = makeRestrictionNoticeView
        self.makeToolbarView = makeToolbarView
        self.makeTransfersSectionView = makeTransfersSectionView
    }
}

public extension PaymentsTransfersCorporateContentViewFactory {
    
    typealias MakeBannerSectionView = (BannerPicker) -> BannerSectionView
    typealias MakeRestrictionNoticeView = () -> RestrictionNoticeView
    typealias MakeTransfersSectionView = () -> TransfersSectionView
    typealias MakeToolbarView = () -> ToolbarView
}
