//
//  MainViewСontroller2.swift
//  ForaBank
//
//  Created by Дмитрий on 02/12/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import Foundation
import CoreData

class MainView_ontroller2: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var roundedEdge: RoundedEdgeView!
    @IBOutlet weak var containerViewController: UIView!
    
    @IBOutlet weak var buyUSD: UILabel!
    @IBOutlet weak var saleUSD: UILabel!
    @IBOutlet weak var rateCBUSD: UILabel!
    
    @IBOutlet weak var buyEUR: UILabel!
    @IBOutlet weak var saleEUR: UILabel!
    @IBOutlet weak var rateCBEUR: UILabel!
    
    var arr: [String] = (0...3).map { return "\($0)" }
    var images: [String] = ["phone", "transfer", "cdpadding", "history"]
    
    var labeltext: [String] = ["Перевод по номеру телефона", "Перевод по номеру карты", "Перевод между своими счетами", "История"]
    var arrayPosition = UserDefaults.standard.stringArray(forKey: "arrayPosition") ?? [String]()
    var arrayImagePosition = UserDefaults.standard.stringArray(forKey: "arrayImagePosition") ?? [String]()
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    lazy var collectionView: UICollectionView =  {
           let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
           let cv: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
           cv.register(Cell.self, forCellWithReuseIdentifier: Cell.id)
        layout.itemSize = CGSize(width: screenWidth/2, height: screenWidth/2.5)
           cv.dataSource = self
        layout.minimumInteritemSpacing = 0
        
        
           cv.addGestureRecognizer(longPressGesture)
           return cv
        
       }()
    

       lazy var longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))

       private var movingCell: MovingCell?

       override func viewDidLoad() {
           super.viewDidLoad()
    
        self.buyUSD.text = ""
        self.buyEUR.text = ""
        self.saleUSD.text = ""
        self.saleEUR.text = ""
        self.rateCBEUR.text = ""
        self.rateCBUSD.text = ""
        
        
        self.getRates()
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        var arrayPosition = UserDefaults.standard.stringArray(forKey: "arrayPosition") ?? [String]()
        if UserDefaults.standard.stringArray(forKey: "arrayPosition") == nil {
                   arrayPosition = labeltext
               }
        labeltext = arrayPosition
        var arrayImagePosition: [String] = UserDefaults.standard.stringArray(forKey: "arrayImagePosition") ?? [String]()
        if UserDefaults.standard.stringArray(forKey: "arrayImagePosition") == nil {
            arrayImagePosition = images
        }
        images = arrayImagePosition
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "mainscreen-1")!)
        self.view.contentMode = UIView.ContentMode.scaleAspectFill
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
               backgroundImage.image = UIImage(named: "mainscreen-1")
               backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        
        containerViewController.addSubview(collectionView)
        roundedEdge.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .white
       
       }
   

       @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {

           var cell: (UICollectionViewCell?, IndexPath?) {
               guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
                let cell = collectionView.cellForItem(at: indexPath) else { return (nil, nil) }
               return (cell, indexPath)
           }

           switch(gesture.state) {

           case .began:
               movingCell = MovingCell(cell: cell.0, originalLocation: cell.0?.center, indexPath: cell.1)
               movingCell?.cell.alpha = 0.5
               break
           case .changed:

               /// Make sure moving cell floats above its siblings.
               movingCell?.cell.layer.zPosition = 100
               movingCell?.cell.center = gesture.location(in: gesture.view!)
               movingCell?.cell.alpha = 0.5
               break
           case .ended:

               swapMovingCellWith(cell: cell.0, at: cell.1)
               movingCell = nil
               movingCell?.cell.alpha = 0.5
           default:
            movingCell?.cell.alpha = 0.5
            movingCell?.reset()
            movingCell = nil
            
        
           }
       }

       func swapMovingCellWith(cell: UICollectionViewCell?, at indexPath: IndexPath?) {
           guard let cell = cell, let moving = movingCell else {
               movingCell?.reset()
               return
           }

           // update data source
           labeltext.swapAt(moving.indexPath.row, indexPath!.row)
            images.swapAt(moving.indexPath.row, indexPath!.row)
           // swap cells
           animate(moving: moving.cell, to: cell)
            UserDefaults.standard.set(labeltext, forKey: "arrayPosition")
        UserDefaults.standard.set(images, forKey: "arrayImagePosition")

       }

       func animate(moving movingCell: UICollectionViewCell, to cell: UICollectionViewCell) {
           longPressGesture.isEnabled = false
           UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.allowUserInteraction, animations: {
               movingCell.center = cell.center
               cell.center = movingCell.center
           }) { _ in
               self.collectionView.reloadData()
               self.longPressGesture.isEnabled = true
           }
        
       }

    
    
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return arr.count
       }
       
       

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell: Cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.id, for: indexPath) as! Cell
        cell.titleLable.text = labeltext[indexPath.row]
        cell.imageView.image = (UIImage(named: images[indexPath.row])!)
        return cell
       }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            

        guard let paymentDetailsVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
                return
            }
     

            let sourceProvider = PaymentOptionCellProvider()
            let destinationProvider = PaymentOptionCellProvider()
            let destinationProviderCardNumber = CardNumberCellProvider()
            let destinationProviderAccountNumber = AccountNumberCellProvider()
            let destinationProviderPhoneNumber = PhoneNumberCellProvider()

            paymentDetailsVC.sourceConfigurations = [
                PaymentOptionsPagerItem(provider: sourceProvider, delegate: paymentDetailsVC)
            ]

       
        
        switch labeltext[indexPath.row]{
            case "Перевод по номеру телефона":
                paymentDetailsVC.destinationConfigurations = [
                    PhoneNumberPagerItem(provider: destinationProviderPhoneNumber, delegate: paymentDetailsVC)
                               ]
               
                break
            case "Перевод по номеру карты":
                paymentDetailsVC.destinationConfigurations = [
                    CardNumberPagerItem(provider: destinationProviderCardNumber, delegate: paymentDetailsVC),
                    AccountNumberPagerItem(provider: destinationProviderAccountNumber, delegate: paymentDetailsVC),
                ]
                break
            case "Перевод между своими счетами":
                 paymentDetailsVC.destinationConfigurations = [
                    PaymentOptionsPagerItem(provider: destinationProvider, delegate: paymentDetailsVC)
                               ]
                break
            case "История":
                let storyboard = UIStoryboard(name: "Deposits", bundle: nil)

                let newVC = storyboard.instantiateViewController(withIdentifier: "DepositsHistoryViewController")
                    self.present(newVC, animated: true, completion: nil)
            break
            default:
                break
            }

            let rootVC = collectionView.parentContainerViewController()
            rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
        

    }

       private struct MovingCell {
           let cell: UICollectionViewCell
           let originalLocation: CGPoint
           let indexPath: IndexPath

           init?(cell: UICollectionViewCell?, originalLocation: CGPoint?, indexPath: IndexPath?) {
               guard cell != nil, originalLocation != nil, indexPath != nil else { return nil }
               self.cell = cell!
               self.originalLocation = originalLocation!
               self.indexPath = indexPath!
           }

           func reset() {
               cell.center = originalLocation
           }
       }

       final class Cell: UICollectionViewCell,UICollectionViewDelegateFlowLayout {
           static let id: String = "CellId"

        
        
           lazy var titleLable: UILabel = UILabel(frame: CGRect(x: 0, y: 20, width: self.bounds.width/2, height: 30))
        
        lazy var imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 20, width: frame.size.height/2, height: frame.size.width/2))
        
        let label = UILabel(frame: CGRect(x:100, y: 30, width: UIScreen.main.bounds.width , height: 40))

        
        
           override init(frame: CGRect) {
               super.init(frame: frame)
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width/3))
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            contentView.addSubview(imageView)
           
            titleLable = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width/1.5, height: 50))
            titleLable.center.x = frame.size.width/2
            titleLable.font = UIFont.systemFont(ofSize: 13)
            titleLable.textColor = .black
            titleLable.textAlignment = .center
            contentView.addSubview(titleLable)
            titleLable.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            titleLable.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
            titleLable.numberOfLines = 20
//            titleLable.trailingAnchor.constraint(equalTo: 30)
               
               
           }

           required init?(coder aDecoder: NSCoder) {
               super.init(coder: aDecoder)
           }
       }
}


//MARK: Rates
private extension MainView_ontroller2{
    
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
    func getRates(){
        // достаем инфу по USD
        self.getExchangeCurrencyRates(currencyName: "USD") { (currency) in
            if currency?.buyCurrency != nil{
                self.buyUSD.text = "\(NSString(format:"%.2f", currency!.buyCurrency!))"
            }
            if currency?.saleCurrency != nil{
                self.saleUSD.text = "\(NSString(format:"%.2f", currency!.saleCurrency!))"
            }
        }
        
        self.getABSCurrencyRates(nameCurrencyFrom: "RUB", nameCurrencyTo: "USD", rateTypeID: 95006809) { (rateCB) in
            if rateCB != nil{
                self.rateCBUSD.text = "\(NSString(format:"%.2f",rateCB!))"
            }
        }
        
        //достаем инфу по EUR
        self.getExchangeCurrencyRates(currencyName: "EUR") { (currency) in
            if currency?.buyCurrency != nil{
                self.buyEUR.text = "\(NSString(format:"%.2f", currency!.buyCurrency!))"
            }
            if currency?.saleCurrency != nil{
                self.saleEUR.text = "\(NSString(format:"%.2f", currency!.saleCurrency!))"
            }
        }
        
        self.getABSCurrencyRates(nameCurrencyFrom: "RUB", nameCurrencyTo: "EUR", rateTypeID: 95006809) { (rateCB) in
            if rateCB != nil{
                self.rateCBEUR.text = "\(NSString(format:"%.2f",rateCB!))"
            }
        }
    }
}
