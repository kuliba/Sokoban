//
//  FirstViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 14/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Hero
import PassKit
import UserNotifications

class LoginOrSignupViewController: UIViewController {
    var error: Unmanaged<CFError>?

    
    
    // MARK: - Properties
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var collectionViewRates: UICollectionView!
    
    
    //
    //    @IBAction func changeServer(_ sender: UIButton, forEvent event: UIEvent) {
//        let actions: [((UIAlertAction) -> Void)?] = [{ (action) in
//            print(action.title ?? "")
//            Host.shared.serverType = .test
//        }, { (action) in
//                print(action.title ?? "")
//                Host.shared.serverType = .production
//            }]
//        AlertService.shared.show(title: "Сменить сервер", message: "Сменить сервер", cancelButtonTitle: "Отмена", okButtonTitles: ["Тест", "Прод"], cancelCompletion: nil, okCompletions: actions)
//    }
    
    let arrayCurrencyName = ["EUR", "USD"] // курсы валют, которые нужнл загрузить на экран

    var arrayCurrency = Array<Currency>(){
           didSet{
               collectionViewRates.reloadData()
           }
       }
    let transitionDuration: TimeInterval = 2

    var segueId: String? = nil
    var animator: UIViewPropertyAnimator? = nil
    var host = Host()

    // MARK: - Lifecycle
    private func setupCollectionView(){
//
//        collectionViewRates.isPagingEnabled = true
//
//        let layoutCard = UICollectionViewFlowLayout()
//        layoutCard.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layoutCard.minimumLineSpacing = 0
//        layoutCard.minimumInteritemSpacing = 0
//        layoutCard.scrollDirection = .horizontal
//
//
//        let layoutRates = UICollectionViewFlowLayout()
//        layoutRates.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layoutRates.minimumLineSpacing = 0
//        layoutRates.minimumInteritemSpacing = 0
//        layoutRates.scrollDirection = .horizontal
//        self.collectionViewRates?.collectionViewLayout = layoutRates
    }
    

    
    @IBOutlet var applePay: PKPaymentButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        host.serverType = .production
        //requesting for authorization
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
              
          })
        
        getAllRates()
        setupCollectionView()
        

//        var applePayButton: PKPaymentButton?
        if !PKPaymentAuthorizationViewController.canMakePayments() {
             // Apple Pay not supported
             return
           }
//        var applePayBuy: PKPaymentButton?
//
//        applePayBuy = PKPaymentButton.init(paymentButtonType: .buy, paymentButtonStyle: .black)
//            applePayBuy?.addTarget(self, action: #selector(self.payPressed(_:)), for: .touchUpInside)
//
//        applePayButton = PKPaymentButton.init(paymentButtonType: .setUp, paymentButtonStyle: .black)
//             applePayButton?.addTarget(self, action: #selector(self.setupPressed(_:)), for: .touchUpInside)
//
//        applePayButton?.translatesAutoresizingMaskIntoConstraints = false
//        self.containerView.addSubview(applePayButton!)
//        applePayButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        applePayButton?.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        applePayButton?.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        applePayButton?.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 20).isActive = true
//
//        applePayBuy?.translatesAutoresizingMaskIntoConstraints = false
//               self.containerView.addSubview(applePayBuy!)
//               applePayBuy?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//               applePayBuy?.widthAnchor.constraint(equalToConstant: 200).isActive = true
//               applePayBuy?.heightAnchor.constraint(equalToConstant: 60).isActive = true
//               applePayBuy?.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -60).isActive = true
//        applePayBuy?.isHidden = true
//        applePayButton?.isHidden = true
//        applePay.isHidden = true

    }
    
    
    @IBAction func buttonCreateNotification(_ sender: Any) {
        

        print("TAP BUTTON")
//        Host.shared.serverType = ServerType.production
        if  self.host.serverType == ServerType.test {
            self.host.serverType = .production
        } else {
            self.host.serverType = .test
        }
        AlertService.shared.show(title: "Сервер изменен", message: "\(self.host.serverType)", cancelButtonTitle: "Ок", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil)
        
        
//        //creating the notification content
//        let content = UNMutableNotificationContent()
//
//        //adding title, subtitle, body and badge
//        content.body = "Вам попытались направить перевод через СБП, но мы не смогли его принять - подключите возможность отправки и получения переводов через СБП в мобильном приложении \n\nДля подключения сервиса перейдите по ссылке: forabank.ru/sbp"
//        content.badge = 1
//
//        //getting the notification trigger
//        //it will be called after 5 seconds
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        //getting the notification request
//        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
//
//        //adding the notification to notification center
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//
        
    }
    
    private var paymentRequest: PKPaymentRequest = {
             let request = PKPaymentRequest()
             request.merchantIdentifier = "merchant.forabank.betaapps"
             request.supportedNetworks = [.visa, .masterCard]
             request.supportedCountries = ["RU"]
             request.merchantCapabilities = .capability3DS
             request.countryCode = "RU"
             request.currencyCode = "RUB"
             request.paymentSummaryItems = [PKPaymentSummaryItem(label: "iPhone Xs 64 Gb", amount: 34999.99)]
             return request
           }()
    
    @objc func payPressed(_ sender: PKPaymentButton){
      if let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
               controller.delegate = self
               present(controller, animated: true, completion: nil)
           }
     }
    
    @objc func setupPressed(_ sender: PKPaymentButton){
      let passLibrary = PKPassLibrary()
      passLibrary.openPaymentSetup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setButtonsAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "SignIn" || segueId == "Registration" || segueId == nil {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "logout" {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        backgroundImageView.alpha = 0
        self.backgroundImageView.transform = CGAffineTransform(translationX: 20, y: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        UIView.animate(withDuration: 2, delay: 0, options: .beginFromCurrentState, animations: {
            self.backgroundImageView.transform = CGAffineTransform.identity
            self.backgroundImageView.alpha = 0.1
        }, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "SignIn" || segueId == "Registration" || segueId == nil {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
    }

//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        print("viewWillLayoutSubviews")
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueId = nil
        if let vc = segue.destination as? SignInViewController {
            segueId = "SignIn"
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
        if let vc = segue.destination as? RegistrationViewController {
            segueId = "Registration"
            vc.segueId = segueId
            vc.backSegueId = segueId
        }
    }

    func setButtonsAppearance() {
        signInButton.backgroundColor = .clear
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.white.cgColor
        signInButton.layer.cornerRadius = signInButton.frame.height / 2

        registrationButton.layer.cornerRadius = registrationButton.frame.height / 2
    }
 
    func getAllRates(){
          for nameRate in arrayCurrencyName{
              getRate(nameCurrency: nameRate)
          }
      }
    
    func getExchangeCurrencyRates(currencyName: String, completionHandler: @escaping (Currency?) -> Void){
        NetworkManager.shared().getExchangeCurrencyRates(currency: currencyName) {(success, currency) in
            guard success, currency != nil else{
                print("Не удалось получить курсы getExchangeCurrencyRates")
                completionHandler(nil)
                return
            }
            completionHandler(currency)
            return
        }
    }
    func getABSCurrencyRates(nameCurrencyFrom: String, nameCurrencyTo: String , rateTypeID: Int, completionHandler: @escaping (Double?) -> Void){
        NetworkManager.shared().getABSCurrencyRates(currencyOne: nameCurrencyFrom, currencyTwo: nameCurrencyTo, rateTypeID: rateTypeID) { (success, rateCB) in
            guard success, rateCB != nil else{
                print("Не удалось получить курсы getABSCurrencyRates")
                completionHandler(nil)
                return
            }
            completionHandler(rateCB)
            return
        }
    }
    
    func getRate(nameCurrency: String){
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
            }else{
                currencyR.nameCurrency = nameCurrency
            }
            
            self?.getABSCurrencyRates(nameCurrencyFrom: "RUB", nameCurrencyTo: nameCurrency, rateTypeID: 95006809) { [weak self](rateCB) in
                if rateCB != nil{
                    currencyR.rateCBCurrency = rateCB!
                }
                self?.arrayCurrency.append(currencyR)
            }
        }
    }

      
}

extension LoginOrSignupViewController: PKPaymentAuthorizationViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
 
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
     
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView == collectionViewRates{
                return arrayCurrency.count
            }
            print("collectionView не определен!!!")
            return 0
            
        }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionFooter) {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartFooterCollectionReusableView", for: indexPath)
        // Customize footerView here
        return footerView
        } else if (kind == UICollectionView.elementKindSectionHeader) {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath)
        // Customize headerView here
        return headerView
    }
    fatalError()
    }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       if collectionView == collectionViewRates{
                if let item = collectionViewRates.dequeueReusableCell(withReuseIdentifier: "cellRate", for: indexPath) as? RateCVC{
                    if arrayCurrency.count != 0{
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
                    }
//                    item.backgroundColor = .green
                    return item
                }
            }
            return UICollectionViewCell()
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{

            return CGSize(width: collectionViewRates.bounds.width, height: 50)

        }
    
}
