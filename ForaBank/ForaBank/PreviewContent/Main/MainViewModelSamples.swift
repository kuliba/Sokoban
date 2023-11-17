//
//  MainViewModelSamples.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

extension MainViewModel {
    
    static let sample = MainViewModel(
        .emptyMock,
        sections: [
            MainSectionProductsView.ViewModel.sample,
            MainSectionFastOperationView.ViewModel.sample,
            MainSectionPromoView.ViewModel.sample,
            MainSectionCurrencyMetallView.ViewModel.sample,
            MainSectionOpenProductView.ViewModel.sample
        ],
        makeOperationStateViewModel: { _  in .preview },
        makeProductProfileViewModel: { _,_,_ in nil },
        onRegister: {}
    )
    
    static let sampleProducts = MainViewModel(
        .emptyMock,
        sections: [
            MainSectionProductsView.ViewModel(.productsMock),
            MainSectionFastOperationView.ViewModel.sample,
            MainSectionPromoView.ViewModel.sample,
            MainSectionCurrencyView.ViewModel.sample,
            MainSectionOpenProductView.ViewModel.sample
        ],
        makeOperationStateViewModel: { _  in .preview },
        makeProductProfileViewModel: { _,_,_ in nil },
        onRegister: {}
    )
    
    static let sampleOldCurrency = MainViewModel(
        .emptyMock,
        sections: [
            MainSectionProductsView.ViewModel(.productsMock),
            MainSectionFastOperationView.ViewModel.sample,
            MainSectionPromoView.ViewModel.sample,
            MainSectionCurrencyView.ViewModel.sample,
            MainSectionOpenProductView.ViewModel.sample
        ],
        makeOperationStateViewModel: { _  in .preview },
        makeProductProfileViewModel: { _,_,_ in nil },
        onRegister: {}
    )
}
