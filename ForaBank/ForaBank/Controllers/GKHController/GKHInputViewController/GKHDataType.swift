//
//  GKHDataType.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2021.
//

import Foundation

final class GKHDataType {
    
    static var personalAccount = ["Лицевой счет": GKHDataFilter.personalAccountArray]
    static var counter         = ["Счетчик": GKHDataFilter.counterArray]
    static var address         = ["Адрес": GKHDataFilter.addressArray]
    static var paymentPeriod   = ["Период оплаты": GKHDataFilter.paymentPeriodArray]
    static var insurance       = ["Страхование": GKHDataFilter.insuranceArray]
    static var phoneNumber     = ["Номер телефона": GKHDataFilter.phoneNumberArray]
    static var summ            = ["Cумма (пени, задолженности)": GKHDataFilter.summArray]
    static var date            = ["Дата": GKHDataFilter.dateArray]
    static var transitonType   = ["Тип перевода": GKHDataFilter.transitonTypeArray]
    static var fio             = ["ФИО": GKHDataFilter.fioArray]
    
}
