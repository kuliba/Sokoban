//
//  PaymentsTransfersViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import UIPrimitives
import AnywayPaymentDomain

//struct ProductProfileViewFactory {
//    
//    let makeHistoryCalendarView: MakeHistoryCalendarView
//}
//
//extension ProductProfileViewFactory {
//    //MAKR: Period optional or not
//    typealias MakeHistoryCalendarView = (Period?) -> HistoryCalendarStateWrapperView
//}

struct PaymentsTransfersViewFactory {
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
    let makeIconView: MakeIconView
    let makeUpdateInfoView: MakeUpdateInfoView
    let makeAnywayPaymentFactory: MakeAnywayPaymentFactory
}

extension PaymentsTransfersViewFactory {
    
    typealias MakeIconView = IconDomain.MakeIconView
    typealias MakeAnywayPaymentFactory = (@escaping (AnywayPaymentEvent) -> Void) -> AnywayPaymentFactory<IconDomain.IconView>
}

//struct HistoryCalendarStateWrapperView: View {
//    
//    @StateObject private var viewModel: HistoryCalendarViewModel
//    
//    var body: some View {
//        
//        HistoryCalendarView(
//            state: viewModel.state,
//            event: viewModel.event,
//            config: .iFora
//        )
//    }
//}
//
//typealias HistoryCalendarViewModel = RxViewModel<Int, String, Never>
