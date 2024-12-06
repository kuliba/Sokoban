//
//  QRTypealiases.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Combine
import ForaTools
import Foundation
import PayHub
import SberQR

typealias CreateSberQRPaymentResult = (Result<CreateSberQRPaymentResponse, MappingRemoteServiceError<MappingError>>)
typealias CreateSberQRPaymentCompletion = (CreateSberQRPaymentResult) -> Void
typealias MakeSberQRConfirmPaymentViewModel = (GetSberQRDataResponse, @escaping (SberQRConfirmPaymentState) -> Void) throws -> SberQRConfirmPaymentViewModel

typealias QRScannerModel = QRModelWrapper<QRModelResult>

typealias SegmentedOperatorProvider = OperatorProvider<SegmentedOperatorData, SegmentedProvider>

typealias SegmentedOperatorData = SegmentedOperator<OperatorGroupData.OperatorData, String>
typealias SegmentedProvider = SegmentedOperator<UtilityPaymentProvider, String>

typealias QRModelResult = PayHub.QRModelResult<SegmentedOperatorData, SegmentedProvider, QRCode, QRMapping, Payments.Operation.Source>
typealias QRMappedResult = PayHub.QRMappedResult<SegmentedOperatorData, SegmentedProvider, QRCode, QRMapping, Payments.Operation.Source>

typealias MixedQRResult = PayHub.MixedQRResult<SegmentedOperatorData, SegmentedProvider, QRCode, QRMapping>
typealias MultipleQRResult = PayHub.MultipleQRResult<SegmentedOperatorData, SegmentedProvider, QRCode, QRMapping>
typealias SinglePayload = PayHub.SinglePayload<SegmentedOperator<OperatorGroupData.OperatorData, String>, QRCode, QRMapping>
typealias ProviderPayload = PayHub.ProviderPayload<SegmentedOperator<UtilityPaymentProvider, String>, QRCode, QRMapping>
