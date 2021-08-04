//
//  BottomLableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import Foundation

/// Модель для отображения поля конвертации валют в BottomInputViewWithRateView
/// Возвращает текст для Lable
/// Возвращает данные для отправки
struct BottomLableModel {
    /// Списываемая сумма
    var currentSumm: String?
    /// Символ списываемой валюты
    var currentSimbol: String?
    /// Символ покупаемой валюты
    var rateSimbol: String?
    /// Курс продажи списываемой валюты
    var currentRate: Double?
    /// Курс покупки валюты перевода
    var rate: Double?
    
}

