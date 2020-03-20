//
//  MainVC.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 19.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    var arrayCards = Array<Card>(){
        didSet{
            print("reloadData")
            collectionViewCard.reloadData()
        }
    }
    var arrayCurrency = Array<Currency>(){
        didSet{
            collectionViewRates.reloadData()
        }
    }
    let arrayCurrencyName = ["EUR", "USD"]
    
    
    @IBOutlet weak var collectionViewCard: UICollectionView!
    @IBOutlet weak var collectionViewRates: UICollectionView!
    @IBOutlet weak var activityDownlandRates: UIActivityIndicatorView! //для обозначение загрузки курсов валют
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        getAllRates() // запрашиваем курс валют
        getCards()
        activityDownlandRates.color = .white
        // Do any additional setup after loading the view.
    }
}

//MARK: CollectionView
extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func setupCollectionView(){
                
        collectionViewCard.isPagingEnabled = true
        collectionViewRates.isPagingEnabled = true
        
        collectionViewCard.backgroundColor = .clear
        collectionViewRates.backgroundColor = .clear
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.collectionViewCard?.collectionViewLayout = layout
        self.collectionViewRates?.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewCard{
            return arrayCards.count
        }else if collectionView == collectionViewRates{
            return arrayCurrency.count
        }else{
            print("collectionView не определен!!!")
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewCard{
            print("1")
            if let item = collectionViewCard.dequeueReusableCell(withReuseIdentifier: "cellCard", for: indexPath) as? CardCVC{
                print("2")
                let card = arrayCards[indexPath.row]
                item.amountCard.text = "\(card.balance)"
                let nameCard = (card.name == nil) ? card.customName : card.name
                item.nameCard.text = "\(nameCard ?? "NO")"
                item.numberCard.text = "*\(card.number.prefix(4))"
                return item
            }
        }else if collectionView == collectionViewRates{
            if let item = collectionViewRates.dequeueReusableCell(withReuseIdentifier: "cellRate", for: indexPath) as? RateCVC{
                if let buyCurrency = arrayCurrency[indexPath.row].buyCurrency{
                    item.buyCurrency.text = "\(NSString(format:"%.2f", buyCurrency))"
                }
                if let saleCurrency = arrayCurrency[indexPath.row].saleCurrency{
                    item.saleCurrency.text = "\(NSString(format:"%.2f", saleCurrency))"
                }
                if let rateCBCurrency = arrayCurrency[indexPath.row].rateCBCurrency{
                    item.cbCarrency.text = "\(NSString(format:"%.2f", rateCBCurrency))"
                }
                if let nameCurrency = arrayCurrency[indexPath.row].nameCurrency{
                    item.currencyCode.text = nameCurrency
                }
                return item
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return collectionView.frame.size
    }
}

//MARK: Rates
private extension MainVC{
    
    func getAllRates(){
        for nameRate in arrayCurrencyName{
            getRate(nameCurrency: nameRate)
        }
    }
    
    //получаем курс валюты
    func getExchangeCurrencyRates(currencyName: String, completionHandler: @escaping (Currency?) -> Void){
        NetworkManager.shared().getExchangeCurrencyRates(currency: currencyName) {(success, currency) in
            guard success, currency != nil else{
                completionHandler(nil)
                return
            }
            completionHandler(currency)
            return
        }
    }
    
    //получаем курс ЦБ
    func getABSCurrencyRates(nameCurrencyFrom: String, nameCurrencyTo: String , rateTypeID: Int, completionHandler: @escaping (Double?) -> Void){
        NetworkManager.shared().getABSCurrencyRates(currencyOne: nameCurrencyFrom, currencyTwo: nameCurrencyTo, rateTypeID: rateTypeID) { (success, rateCB) in
            guard success, rateCB != nil else{
                completionHandler(nil)
                return
            }
            completionHandler(rateCB)
            return
        }
    }
    
    //заполняем данные по курсу
    func getRate(nameCurrency: String){
        self.activityDownlandRates.startAnimating()
        self.activityDownlandRates.isHidden = false
        let currencyR = Currency()
        self.getExchangeCurrencyRates(currencyName: nameCurrency) { [weak self](currency) in
            if currency?.buyCurrency != nil{
                currencyR.buyCurrency = currency!.buyCurrency!
            }
            if currency?.saleCurrency != nil{
                currencyR.saleCurrency = currency!.saleCurrency!
            }
            if currency?.nameCurrency != nil{
                currencyR.nameCurrency = currency?.nameCurrency!
            }
            
            self!.getABSCurrencyRates(nameCurrencyFrom: "RUB", nameCurrencyTo: nameCurrency, rateTypeID: 95006809) { [weak self](rateCB) in
                if rateCB != nil{
                    currencyR.rateCBCurrency = rateCB!
                }
                self!.activityDownlandRates.stopAnimating()
                self!.activityDownlandRates.isHidden = true
                self!.arrayCurrency.append(currencyR)
            }
        }
    }
}

//MARK: Get Cards
private extension MainVC{
    func getCards(){
        print("запрос ушел")
        NetworkManager.shared().getCardList { [weak self](success, cards) in
            if success{
                print("Запрос пришел")
                guard cards != nil else {
                    return
                }
                self!.arrayCards.removeAll()
                self!.arrayCards = cards!
            }
        }
    }
}
