//
//  QRNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.10.2024.
//

import SberQR
@testable import ForaBank
import ForaTools
import XCTest

class QRNavigationTests: XCTestCase {
    
    func makeErrorMessage(
        title: String = anyMessage(),
        message: String = anyMessage()
    ) -> QRNavigation.ErrorMessage {
        
        return .init(title: title, message: message)
    }
    
    func makeMakeOperatorSearchPayload(
        multiple: MultiElementArray<SegmentedOperatorData>? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil,
        chat: @escaping () -> Void = {},
        detailPayment: @escaping () -> Void = {},
        dismiss: @escaping () -> Void = {}
    ) -> QRNavigationComposerMicroServices.MakeOperatorSearchPayload {
        
        return .init(
            multiple: multiple ?? makeMultipleOperators(),
            qrCode: qrCode ?? makeQR(),
            qrMapping: qrMapping ?? makeQRMapping(),
            chat: chat,
            detailPayment: detailPayment,
            dismiss: dismiss
        )
    }
    
    func makeMixed(
    ) -> (mixed: MultiElementArray<SegmentedOperatorProvider>, qrCode: QRCode, qrMapping: QRMapping) {
        
        return (makeMixedOperators(), makeQR(), makeQRMapping())
    }
    
    func makeMixedOperators(
        _ first: SegmentedOperatorProvider? = nil,
        _ second: SegmentedOperatorProvider? = nil,
        _ tail: SegmentedOperatorProvider...
    ) -> MultiElementArray<SegmentedOperatorProvider> {
        
        return .init(first ?? makeSegmentedOperatorProvider(), second ?? makeSegmentedOperatorProvider(), tail)
    }
    
    private func makeSegmentedOperatorProvider(
    ) -> SegmentedOperatorProvider {
        
        return .provider(.init(
            origin: .init(
                id: anyMessage(),
                icon: nil,
                inn: nil,
                title: anyMessage(),
                segment: anyMessage()
            ),
            segment: anyMessage()
        ))
    }
    
    func makeMultipleOperators(
        first: SegmentedOperatorData? = nil,
        second: SegmentedOperatorData? = nil,
        tail: SegmentedOperatorData...
    ) -> MultiElementArray<SegmentedOperatorData> {
        
        return .init(first ?? makeSegmentedOperatorData(), second ?? makeSegmentedOperatorData(), tail)
    }
    
    func makeOperatorGroupDataOperatorData(
        city: String? = nil,
        code: String = anyMessage(),
        isGroup: Bool = false,
        logotypeList: [OperatorGroupData.LogotypeData] = [],
        name: String = anyMessage(),
        parameterList: [ParameterData] = [],
        parentCode: String = anyMessage(),
        region: String? = nil,
        synonymList: [String] = []
    ) -> OperatorGroupData.OperatorData {
        
        return .init(city: city, code: code, isGroup: isGroup, logotypeList: logotypeList, name: name, parameterList: parameterList, parentCode: parentCode, region: region, synonymList: synonymList)
    }
    
    func makeQR(
        original: String = anyMessage(),
        rawData: [String: String] = [anyMessage(): anyMessage()]
    ) -> QRCode {
        
        return .init(original: original, rawData: rawData)
    }
    
    func makeQRMapping(
        parameters: [QRParameter] = [],
        operators: [QROperator] = []
    ) -> QRMapping {
        
        return .init(parameters: parameters, operators: operators)
    }
    
    func makeSberQRConfirmPaymentState(
    ) -> SberQRConfirmPaymentState {
        
        return .init(confirm: .editableAmount(.preview))
    }
    
    func makeSegmentedOperatorData(
        origin: OperatorGroupData.OperatorData? = nil,
        segment: String = anyMessage()
    ) -> SegmentedOperatorData {
        
        return .init(origin: origin ?? makeOperatorGroupDataOperatorData(), segment: segment)
    }
}
