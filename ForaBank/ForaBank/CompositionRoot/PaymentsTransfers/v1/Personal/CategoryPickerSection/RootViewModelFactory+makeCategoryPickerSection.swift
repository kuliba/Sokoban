//
//  RootViewModelFactory+makeCategoryPickerSection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.10.2024.
//

import CombineSchedulers
import ForaTools
import Foundation
import GenericRemoteService
import PayHub
import SberQR

extension RootViewModelFactory {
    
    func makeCategoryPickerSection(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> CategoryPickerSectionDomain.Binder {
        
        let pageSize = settings.pageSize
        let placeholderCount = settings.categoryPickerPlaceholderCount
        
        let makeStandard = makeStandard(
            loadLatestForCategory: nanoServices.loadLatestForCategory,
            loadOperators: loadOperators,
            loadOperatorsForCategory: loadOperatorsForCategory,
            pageSize: pageSize,
            mainScheduler: schedulers.main
        )
        
        let selectedCategoryComposer = SelectedCategoryNavigationMicroServicesComposer(
            model: model,
            nanoServices: .init(
                makeMobile: makeMobilePayment,
                makeQR: makeQRScannerModel,
                makeQRNavigation: getQRNavigation,
                makeStandard: makeStandard,
                makeTax: makeTaxPayment,
                makeTransport: makeTransportPayment
            ),
            scheduler: schedulers.main
        )
        let microServices = selectedCategoryComposer.compose()
        
        let categoryPickerComposer = CategoryPickerSectionDomain.BinderComposer(
            load: nanoServices.loadCategories,
            reload: nanoServices.reloadCategories,
            microServices: microServices,
            placeholderCount: placeholderCount,
            scheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
        )
        
        return categoryPickerComposer.compose(
            prefix: [],
            suffix: (0..<placeholderCount).map { _ in .placeholder(.init()) }
        )
        
        func makeSegmented(
            multi: MultiElementArray<SegmentedOperatorProvider>,
            qrCode: QRCode,
            qrMapping: QRMapping
        ) -> SegmentedPaymentProviderPickerFlowModel {
            
            let make = makeSegmentedPaymentProviderPickerFlowModel(
                pageSize: pageSize
            )
            
            return make(multi, qrCode, qrMapping)
        }
        
        func makeServicePicker(
            payload: PaymentProviderServicePickerPayload,
            completion: @escaping (AnywayServicePickerFlowModel) -> Void
        ) {
            let servicePickerComposer = makeAnywayServicePickerFlowModelComposer()
            
            completion(servicePickerComposer.compose(payload: payload))
        }
        
        func getQRNavigation(
            qrResult: QRModelResult,
            notify: @escaping QRNavigationComposer.Notify,
            completion: @escaping (QRNavigation) -> Void
        ) {
            let microServicesComposer = QRNavigationComposerMicroServicesComposer(
                httpClient: httpClient, 
                logger: logger,
                model: model,
                createSberQRPayment: createSberQRPayment,
                getSberQRData: getSberQRData,
                makeSegmented: makeSegmented,
                makeServicePicker: makeServicePicker,
                scanner: scanner,
                scheduler: schedulers.main
            )
            let microServices = microServicesComposer.compose()
            let composer = QRNavigationComposer(microServices: microServices)
            
            composer.getNavigation(
                payload: .qrResult(qrResult),
                notify: notify,
                completion: completion)
        }
    }
    
    typealias MakeStandard = CategoryPickerSectionMicroServicesComposerNanoServices.MakeStandard
    /*private*/ typealias LoadLatestForCategory = (ServiceCategory, @escaping (Result<[Latest], Error>) -> Void) -> Void
    /*private*/ typealias LoadOperators = (UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload, @escaping ([PaymentServiceOperator]) -> Void) -> Void
    /*private*/ typealias LoadOperatorsForCategory = (ServiceCategory, @escaping (Result<[PaymentServiceOperator], Error>) -> Void) -> Void
    
    /*private*/ func makeStandard(
        loadLatestForCategory: @escaping LoadLatestForCategory,
        loadOperators: @escaping LoadOperators,
        loadOperatorsForCategory: @escaping LoadOperatorsForCategory,
        pageSize: Int,
        mainScheduler: AnySchedulerOf<DispatchQueue>
    ) -> MakeStandard {
        
        return { category, completion in
            
            let microServicesComposer = UtilityPrepaymentMicroServicesComposer(
                pageSize: pageSize,
                nanoServices: .init(loadOperators: loadOperators)
            )
            let standardNanoServicesComposer = StandardSelectedCategoryDestinationNanoServicesComposer(
                loadLatest: loadLatestForCategory,
                loadOperators: loadOperatorsForCategory,
                makeMicroServices: microServicesComposer.compose,
                model: self.model,
                scheduler: mainScheduler
            )
            let standardNanoServices = standardNanoServicesComposer.compose(category: category)
            let composer = StandardSelectedCategoryDestinationMicroServiceComposer(
                nanoServices: standardNanoServices
            )
            let standardMicroService = composer.compose()
            
            standardMicroService.makeDestination(category, completion)
        }
    }
}
