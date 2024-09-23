//
//  MainViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import SwiftUI

struct MainViewFactory {
    
    let makeAnywayPaymentFactory: MakeAnywayPaymentFactory
    let makeIconView: MakeIconView
    let makePaymentCompleteView: MakePaymentCompleteView
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeInfoViews: RootViewFactory.MakeInfoViews
    let makeUserAccountView: MakeUserAccountView
}

extension MainViewFactory {
    
    func iconView(
        _ icon: String?
    ) -> IconDomain.IconView {
        
        makeIconView(icon.map { .md5Hash(.init($0)) })
    }
    
    func labelWithIcon(
        title: String,
        subtitle: String? = nil,
        icon: String?
    ) -> some View {
        
        LabelWithIcon(
            title: title,
            subtitle: subtitle,
            config: .iFora,
            iconView: iconView(icon)
        )
    }
}
