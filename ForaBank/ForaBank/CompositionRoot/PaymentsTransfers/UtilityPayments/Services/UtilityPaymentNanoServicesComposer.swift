//
//  UtilityPaymentNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

final class UtilityPaymentNanoServicesComposer {
    
    private let model: Model
    private let flag: Flag
    
    init(
        model: Model,
        flag: Flag
    ) {
        self.model = model
        self.flag = flag
    }
}

extension UtilityPaymentNanoServicesComposer {
    
    func compose() -> NanoServices {
        #warning("add flag and switch between live and stub")
        return .init(
            getOperatorsListByParam: getOperatorsListByParam,
            getAllLatestPayments: getAllLatestPayments
        )
    }
}

extension UtilityPaymentNanoServicesComposer {
    
    typealias Flag = StubbedFeatureFlag.Option
    
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
}

private extension UtilityPaymentNanoServicesComposer {
    
    /// `b`
    /// Получаем список ЮЛ НКОРР по типу ЖКХ из локального справочника dict/getOperatorsListByParam?operatorOnly=true&type=housingAndCommunalService (b)
    func getOperatorsListByParam(
        pageSize: Int,
        _ completion: @escaping ([Operator]) -> Void
    ) {
        model.loadOperators(.init(pageSize: pageSize), completion)
    }
    
    /// `c`
    /// Получение последних платежей по ЖКХ
    /// rest/v2/getAllLatestPayments?isServicePayments=true
    func getAllLatestPayments(
        _ completion: @escaping ([LastPayment]) -> Void
    ) {
        #warning("FIXME")
        fatalError("unimplemented")
    }
}
