//
//  ProductProfileServices.swift
//  Vortex
//
//  Created by Andryusina Nataly on 29.06.2024.
//

import Foundation
import GetInfoRepeatPaymentService
import LandingMapping
import LandingUIComponent
import SavingsAccount
import PDFKit

struct ProductProfileServices {
    
    let createBlockCardService: BlockCardServices
    let createUnblockCardService: UnblockCardServices
    let createUserVisibilityProductsSettingsService: UserVisibilityProductsSettingsServices
    let createCreateGetSVCardLimits: GetSVCardLimitsServices
    let createChangeSVCardLimit: ChangeSVCardLimitServices
    let createSVCardLanding: SVCardLandingServices
    let getSavingsAccountInfo: GetSavingsAccountInfo
    let getSavingsAccountPrintForm: GetSavingsAccountPrintForm
    let repeatPayment: RepeatPayment
    
    let makeSVCardLandingViewModel: (Landing, ListHorizontalRectangleLimitsViewModel?, UILanding.Component.Config, @escaping (LandingEvent) -> Void
    ) -> LandingWrapperViewModel?
    
    let makeInformer: (String) -> Void
    
    typealias LimitType = String
    
    typealias OperationID = Int
    typealias ActiveProductID = ProductData.ID
    typealias CloseAction = () -> Void
    typealias RepeatPayment = (GetInfoRepeatPaymentDomain.PaymentPayload, @escaping CloseAction, @escaping (PaymentsDomain.Navigation?) -> Void) -> Void

    typealias GetSavingsAccountInfo = (ProductData, @escaping (SavingsAccountDetailsState?) -> Void) -> Void
    typealias GetSavingsAccountPrintForm = (Int, @escaping (PDFDocument?) -> Void) -> Void
}

// MARK: - Preview Content

extension ProductProfileServices {
    
    static let preview: Self = .init(
        createBlockCardService: .preview(),
        createUnblockCardService: .preview(),
        createUserVisibilityProductsSettingsService: .preview(),
        createCreateGetSVCardLimits: .preview(),
        createChangeSVCardLimit: .preview(),
        createSVCardLanding: .preview(),
        getSavingsAccountInfo: { _,_ in }, 
        getSavingsAccountPrintForm: { _,_  in },
        repeatPayment: { _,_,_ in },
        makeSVCardLandingViewModel: { _,_,_,_ in nil },
        makeInformer: { _ in }
    )
}
