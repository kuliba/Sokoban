//
//  ExtensionBottomInputViewWithRateView.swift
//  Vortex
//
//  Created by Константин Савялов on 03.08.2021.
//

import Foundation

extension BottomInputViewWithRateView  {
    /// MARK - Exchange Rate
    
    final func reversedRate( _ from: String, _ whereTo: String) {
        
        guard let text = self.amountTextField.text else { return }
        guard let unformatText = self.moneyFormatter.unformat(text) else { return }
        let (fromValue, whereValue) = (from, whereTo)
        
        let ru = (from == "RUB" || whereTo == "RUB")
        
        switch ru {
               case true:
            /// Если одна из валют выбранной карты в рублях, то ищем которая
            if from != whereTo {
                switch (fromValue, whereValue) {
                case ("RUB", let(value)):
                    let body = [ "currencyCodeAlpha" : value] as [String: AnyObject]
                    
                    NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], body) {[weak self] model, error in
                        let m = model?.data
                        
                        self?.bottomLable.currentSimbol = "₽"
                        /// Курс продажи списываемой валюты
                        self?.bottomLable.currentRate = m?.rateSell
                        /// Списываемая сумма
                        self?.bottomLable.currentSumm = unformatText
                        /// Символ покупаемой валюты
                        self?.bottomLable.rateSimbol = value.getSymbol()
                        /// Курс покупки валюты перевода
                        self?.bottomLable.rate = 0
                        
                        self?.currencySymbol = "₽"
                        self?.requestModel = (to: "RUB", from: value)
                        DispatchQueue.main.async {
                            self?.buttomLabel.text = self?.bottomLable.reversRate()
                            self?.currencySwitchButton.setTitle("₽" + " ⇆ " + (value.getSymbol() ?? ""), for: .normal)
                        }
                    }
                    
                case (let(value), "RUB"):
                    let body = [ "currencyCodeAlpha" : value] as [String: AnyObject]
                    NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], body) { [weak self] model, error in
                        let m = model?.data
                        self?.bottomLable.currentSimbol = "₽" //m?.currencyCodeAlpha?.getSymbol()
                        /// Курс продажи списываемой валюты
                        self?.bottomLable.currentRate = m?.rateBuy
                        /// Списываемая сумма
                        self?.bottomLable.currentSumm = unformatText
                        /// Символ покупаемой валюты
                        self?.bottomLable.rateSimbol = value.getSymbol()
                        /// Курс покупки валюты перевода
                        self?.bottomLable.rate = 0
                        self?.requestModel = (to: value, from: "RUB")
                        self?.currencySymbol = value.getSymbol() ?? ""
                        
                        DispatchQueue.main.async {
                            self?.buttomLabel.text = self?.bottomLable.secondRate()
                            self?.currencySwitchButton.setTitle((value.getSymbol() ?? "") + " ⇆ " + "₽", for: .normal)
                        }
                    }
                case (_, _):
                    break
                }
            }
        case false:
            /// Если обе валюты в выбранных картах в рублях не в рублях
            // Из
            let bodyFrom = [ "currencyCodeAlpha" : from] as [String: AnyObject]
            // В
            let bodyTo = [ "currencyCodeAlpha" : whereTo] as [String: AnyObject]
            NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], bodyFrom) { [weak self] model, error in
                let tempModel = model?.data
                self?.bottomLable.currentSimbol = tempModel?.currencyCodeAlpha?.getSymbol()
                /// Курс продажи списываемой валюты
                self?.bottomLable.currentRate = tempModel?.rateBuy
                /// Списываемая сумма
                self?.bottomLable.currentSumm = unformatText
                /// Символ покупаемой валюты
                NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], bodyTo) {[weak self]
                    modelTo, error in
                    let m = modelTo?.data
                    self?.bottomLable.rateSimbol = m?.currencyCodeAlpha?.getSymbol()
                    /// Курс покупки валюты перевода
                    self?.bottomLable.rate = m?.rateSell
                    self?.requestModel = (to: tempModel?.currencyCodeAlpha ?? "", from: m?.currencyCodeAlpha ?? "")
                    self?.currencySymbol = from.getSymbol() ?? ""
                    DispatchQueue.main.async {
                        self?.buttomLabel.text = self?.bottomLable.anyRate()
                        self?.currencySwitchButton.setTitle((tempModel?.currencyCodeAlpha?.getSymbol() ?? "") + " ⇆ " + (m?.currencyCodeAlpha?.getSymbol() ?? ""), for: .normal)
                    }
                }
            }
        }
    }
}
