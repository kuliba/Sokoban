//
//  ExtensionBottomLableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.08.2021.
//

import Foundation

extension BottomLableModel {
    
    init(_ simbol: (String, String),
         _ currentSumm: String,
         _ carrentRate: Double,
         _ rate: Double) {
        self.currentSimbol = simbol.0.getSymbol()
        self.rateSimbol = simbol.1.getSymbol()
        self.currentSumm = currentSumm
        self.currentRate = carrentRate
        self.rate = rate
    }
    
    /// Расчет суммы конверсии, если первая валюта не рубль
    func secondRate() -> String {
        let a = String((currentRate ?? 0).rounded(toPlaces: 2))
        let summ = String(((currentSumm?.toDouble() ?? 0) * (currentRate ?? 0)).rounded(toPlaces: 2))
        let bottomLableText = summ + (currentSimbol ?? "") + "  |  " + "1" + (rateSimbol ?? "") + " - " + a + "₽"
        return bottomLableText
    }
    
    /// Расчет суммы конверсии, если первая валюта рубль
    func firstRate() -> String {
        let a = String((currentRate ?? 0).rounded(toPlaces: 2))
        let summ = String(((currentSumm?.toDouble() ?? 0) / (currentRate ?? 0)).rounded(toPlaces: 2))
        let bottomLableText = summ + (rateSimbol ?? "") + "  |  " + "1" + (rateSimbol ?? "") + " - " + a + "₽"
        return bottomLableText
    }
    
    /// Расчет суммы конверсии, когда ни одна из валют не рубли
    func anyRate() -> String {
        let a = String((rate ?? 0).rounded(toPlaces: 2))
        let summ = currentSumm?.toDouble() ?? 0
        let b = (self.currentRate ?? 0) / (self.rate ?? 0)
        let resultSum = String((summ * b).rounded(toPlaces: 2))
        let bottomLableText = resultSum + (rateSimbol ?? "") + "  |  " + "1" + (rateSimbol ?? "") + " - " + a + (currentSimbol ?? "")
        return bottomLableText
    }
    
    /// Расчет суммы конверсии при перестановке валют
    func reversRate() -> String {
        let a = String((currentRate ?? 0).rounded(toPlaces: 2))
        let summ = String(((currentSumm?.toDouble() ?? 0) / (currentRate ?? 0)).rounded(toPlaces: 2))
        let bottomLableText = summ + (rateSimbol ?? "") + "  |  " + "1" + (rateSimbol ?? "") + " - " + a + "₽"
        return bottomLableText
    }
}
