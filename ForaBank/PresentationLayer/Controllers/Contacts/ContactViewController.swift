//
//  ContactViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

struct ParametrField: Codable{
    var fieldName: String
    var fieldId: Int
    var fieldValue: String
    init(fieldName: String?, fieldId: Int?, fieldValue: String?) throws {
        self.fieldId = fieldId ?? 0
        self.fieldValue = fieldValue ?? ""
        self.fieldName = fieldName ?? ""
    }
}


class ContactViewController: UIViewController, ListOperationViewControllerProtocol {
    
    var tableViewHeightConstraint: CGFloat?
    var activityView: RefreshView?
    var puref: String?
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        setConnectionWithService()
    }
    var patronymic: String?

    var countInputEmpty: Int?
    var setCountry: String?
    var parametersList: [Additional] = []{
        didSet{
            let filterDataTv = parametersList.filter({$0.fieldname != "bSurName"})
            let newFilter = filterDataTv.filter({$0.fieldname != "A"})
            let lastFilter = newFilter.filter({$0.fieldvalue != ""})
            if lastFilter.count < 4, amountTextField.text == "" {
                continueButton.reloadInputViews()
//                continueButton.changeEnabled(isEnabled: false)
//                continueButton.isEnabled = false
//                continueButton.alpha = 0.5
            } else if lastFilter.count >= dataList?.count ?? 0, amountTextField.text != ""{
                continueButton.isEnabled = true
                continueButton.alpha = 1
            } else {
                continueButton.reloadInputViews()
                continueButton.changeEnabled(isEnabled: false)
                continueButton.isEnabled = false
                continueButton.alpha = 0.5
            }
            
        }
    }
    
    var params: ParametrField?{
        didSet{
//            setParameters()
        }
    }
    var idCountry: String?
    
    @IBOutlet weak var pagerView: PagerView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    var headerTitleText: String?
   
    @IBOutlet weak var CurrentlyLabel: UIButton!
    
    @IBOutlet weak var tableViewStackView: UIStackView?
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var continueButton: ButtonRounded!
    @IBAction func backButtonClicker(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func changeCurrently(_ sender: Any) {
        guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ListOperationViewController") as? ListOperationViewController else {
                                 return
                             }
        vc.titleText = "Валюта выдачи перевода"
        vc.listArray = self.clearArrayList
        present(vc, animated: true, completion:  nil)
        
    }
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var headerView: MaskedNavigationBar!
    @IBOutlet weak var bottomView: UIView!
    
    var sourceConfigurations: [ICellConfigurator]?
    var sourceValue: PaymentOption? {
        didSet {
            if firstTimeRequestSourceView ?? true {
            setConnectionWithService()
            }
        }
    }
    var sourceConfig: Any?
    var numberCard: String?
    var firstTimeRequest: Bool?

    var parameters: [Additional]? = []{
        willSet{
            guard let filterNilField = parameters?.filter({$0.fieldvalue != ""})  else {
                return
            }
            let filterNoSurName = filterNilField.filter({$0.fieldname != "bSurName"})
            
            if filterNoSurName.count == 3, firstTimeRequest ?? true, puref != "iFora||Addressing"  {
                loaderTableView()
//                continueButton.isEnabled = true
                    NetworkManager.shared().getAnywayPaymentBegin(numberCard: getSourceValue(), puref: puref) { [self] (success, data, errorMessage) in
                        if success{
                            NetworkManager.shared().getAnywayPayment { [self] (success, data, errorMessage) in
                //                    data.filter({$0 ?.data?.listInputs?[0].readOnly == false})
                                if errorMessage == nil{
                                    NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: self.parameters) { [self] (success, data, errorMessage) in
                                        if success ?? false{
                                            if data[0]?.data?.finalStep == 1{
                                                guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "CodeVerificationStroyboard") as? RegistrationCodeVerificationViewController else {
                                                                         return
                                                                     }
                            //                    vc.operationSum =   data[0]?.data?.amount
                            //                    vc.commission = data[0]?.data?.commission
                                                vc.sourceConfig = sourceConfig
                                                vc.sourceValue = sourceValue
                                                self.present(vc, animated: true, completion: nil)
                                                firstTimeRequest = false

                                            }
                                            self.dataList?.append(contentsOf: (data[0]?.data?.listInputs)!)
                                            loaderEnd()
                                            firstTimeRequest = false

                                        } else {
                                            loaderEnd()
                                            AlertService.shared.show(title: "Ошибка", message: "\(errorMessage!)", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                                            firstTimeRequest = false

                                        }
                                    }
                                } else {
                                    loaderEnd()
                                    errorLabel.text = errorMessage
                                    refreshView.isHidden = true
                                    firstTimeRequest = false

                                }
                            }
                        } else {
                            loaderEnd()
                            errorLabel.text = errorMessage
                            refreshView.isHidden = true
                            firstTimeRequest = true

                        
                    }
                }
                firstTimeRequest = false
            }
//            tableView.reloadData()
        }
    }
    
    var delegate: OperationDetailViewControllerDelegate?
    var dataSelect: String?
    var clearArrayList: [[String]] = []
    var dataListTV: [ListInput?]?{
        didSet{
            tableView.reloadData()
            viewDidAppear(true)
            viewDidLayoutSubviews()
//            tableViewHeightConstraint.constant = 80 * dataListTV!.count ?? 0 ?? 0
        }
    }
//    var tableViewHeightConstraint:
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        var frame = tableView.frame
//           frame.size.height = 68
//           tableView.frame = frame
//        self.tableView.rowHeight = 100.0
        if dataListTV?.count == 1 {
            tableView.heightConstaint?.constant = 80
        } else if dataListTV?.count ?? 0 <= 5{
            tableView.heightConstaint?.constant = CGFloat((dataListTV?.count ?? 1) * 70)
        } else {
            tableView.heightConstaint?.constant = 340
        }


    }
    
    var dataList: [ListInput?]?{
        didSet{
            dataListTV = self.dataList?.filter({$0?.name != "Сумма перевода в валюте выдачи"})
            tableView.reloadData()
        }
    }
    
    func loaderTableView(){
        loaderView.addSubview(activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.startAnimation()
        loaderView.isHidden = false
        amountTextField.isEnabled = false
        tableView.alpha = 0.5
        tableView.isUserInteractionEnabled = false
    }
    func loaderEnd(){
        amountTextField.isEnabled = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        loaderView.isHidden = true
        tableView.alpha = 1
        tableView.isUserInteractionEnabled = true
    }
    
    var dissmiss: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        activityView?.imgVLogo?.image = UIImage(named: "forabank")
        activityView?.imgVBG?.image = UIImage(named: "forabank")
        RefreshView.shared.startAnimation()
        activityView?.frame.size.height = 100
        activityView?.frame.size.width = 100
        tableView.addSubview(activityView ?? UIView())
        activityView?.startAnimation()
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
        refreshView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimation()
        tableView.addSubview(activityIndicator)

        let sourceProvider = PaymentOptionCellProvider()
        sourceConfigurations = [
        PaymentOptionsPagerItem(provider: sourceProvider, delegate: self)
        ]
        
        if let source = sourceConfigurations{
            pagerView.setConfig(config: source)
          }
    
        
        headerTitle.text = headerTitleText
//        pickerView.backgroundColor = .white
        headerView.backgroundColor = UIColor(hexFromString: "ED433D")
//        self.tableView.register(LoansCell.self, forCellReuseIdentifier: "LoansCell")
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if dissmiss ?? false{
            continueButton.alpha = 1
            continueButton.isEnabled = true
        }
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    var item = 0

  func setParameters() -> [Additional]{
//        var parametersList: [Additional] = []
//        self.parameters?.removeAll()
        parametersList.removeAll()
        self.item = 0
        for i in dataList ?? [] {
            self.item += 1
            if i?.content?.count == 0{
//                AlertService.shared.show(title: "Ошибка", message: "Заполните все поля", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
            } else {
//                (fieldName: i?.id!, fieldId: item, fieldValue: i?.content![0])
//                (fieldid: i?.id, fieldname: item, fieldvalue: (i?.content![0]))
                let parameterItem = Additional(fieldid: item, fieldname: i?.id!, fieldvalue: i?.content![0])
    
                self.parameters?.append(parameterItem)
                
              
                parametersList.append(parameterItem)
                parametersList.append(Additional(fieldid: 4, fieldname: "SumSTrs", fieldvalue: amountTextField.text))
                parametersList.append(Additional(fieldid: 4, fieldname: "A", fieldvalue: amountTextField.text))
//                parametersList.append( Additional(fieldid: 20, fieldname: "CURR", fieldvalue: "RUR"))

            }
        }
        return parametersList
    }
    func getSourceValue() -> String{
        switch sourceValue?.productType {
        case .account:
            
            let accountId = "\(String(sourceValue?.id ?? 0.0).dropLast(2))"
            return accountId
        default:
            return sourceValue?.number ?? ""
        }
    }
        
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBAction func amountChangeValue(_ sender: UITextField) {
        for i in dataListTV ?? [] {
            if i?.content?.isEmpty == false, amountTextField.text == ""{
                continueButton.isUserInteractionEnabled = true
                continueButton.alpha = 1
                continueButton.isEnabled = true
            } else {
                continueButton.isUserInteractionEnabled = false
                continueButton.alpha = 0.5
                continueButton.isEnabled = false
                    break
            }
        }
        continueButton.isUserInteractionEnabled = true
        continueButton.alpha = 1
        continueButton.isEnabled = true
    }
    
    @IBAction func paymentAction(_ sender: Any) {
        loaderTableView()
//        self.parameters?.removeAll()
        if dataList!.count > 5{
            dataList?[4]?.content?.removeAll()
            dataList?[4]?.content?.append(amountTextField.text ?? "")
        }
//        self.parameters = setParameters()
        if  dataList?[0]?.name == "Страна выдачи перевода"{
            loaderTableView()
            self.parameters = setParameters()
                    NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: self.parameters) { [self] (success, data, errorMessage) in
                        if success ?? false{
                            if data[0]?.data?.finalStep == 1{
                                guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "CodeVerificationStroyboard") as?   RegistrationCodeVerificationViewController else {
                                                         return
                                                     }
                                vc.segueId = "serviceOperation"
                                vc.operationSum = maskSum(sum: data[0]?.data?.amount ?? 0.0)
                                vc.commission = maskSum(sum: data[0]?.data?.commission ?? 0.0)
                                vc.sourceValue = self.sourceValue
                                vc.sourceConfig = sourceConfig
                                var name = String()
                                var surName = String()
                                var lastName = String()
                                for i in dataListTV ?? [] {
                                    if i?.content?.isEmpty == false{
                                    switch i?.name {
                                    case "Фамилия получателя":
                                            surName += (i?.content?[0])!
                                    case "Имя получателя":
                                            name += (i?.content?[0])!
                                    case "Отчество получателя":
                                            lastName += (i?.content?[0])!
                                    default:
                                        break
                                    }
                                    }
                                    
                                }
                                vc.destinationValue = "\(surName )" + " " + "\(name)" + " " + "\(lastName)"  + "."
                                
//                                    "\(dataListTV?[1]?.content?[0] ?? "")" + " " + "\(patronymic ?? "")" + " " + "\(dataListTV?[0]?.content?[0][0] ?? "")"  + "."
                                vc.phone = ""
                                vc.currencyLable = dataListTV?[9]?.content?[0]
                                // conv data.amount
                                vc.countryValue =  setCountry
                                vc.numberTransferValue = data[0]?.data?.id
                                vc.amountRurCurrently = maskSum(sum: data[0]?.data?.amount ?? 0.0 )
                                self.continueButton.isEnabled = true
                                self.continueButton.alpha = 1
                                dissmiss = true
                                self.present(vc, animated: true, completion: nil)
                            }
//                                    self.dataList?.append(contentsOf: (data[0]?.data?.listInputs)!)
                            loaderEnd()
                        } else {
                            loaderEnd()
                            AlertService.shared.show(title: "Ошибка", message: "\(errorMessage!)", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                        }
                    }
//                                    self.dataList?.append(contentsOf: (data[0]?.data?.listInputs)!)
//                                    loaderEnd()
        } else if dataList!.count >= 6 {
            
            loaderTableView()
            self.parameters = setParameters()
            
            NetworkManager.shared().getAnywayPaymentBegin(numberCard: getSourceValue(), puref: puref) { [self] (success, data, errorMessage) in
                
                if success{
                    NetworkManager.shared().getAnywayPayment { [self] (success, data, errorMessage) in
        //                    data.filter({$0 ?.data?.listInputs?[0].readOnly == false})
                        if errorMessage == nil{
//                            guard let dataList = data[0]?.data?.listInputs?.filter({ $0.readOnly == false }) else { return}
//                            self.dataList = dataList
        
                            NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: self.parameters) { [self] (success, data, errorMessage) in
                                if success ?? false{
                                    NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: self.parameters) { [self] (success, data, errorMessage) in
                                        if success ?? false{
                                            if data[0]?.data?.finalStep == 1{
                                                guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "CodeVerificationStroyboard") as? RegistrationCodeVerificationViewController else {
                                                                         return
                                                                     }
                                                vc.segueId = "contactViewController"
                                                vc.operationSum = data[0]?.data?.listInputs?[1].content?[0]
                                                vc.commission = maskSum(sum: data[0]?.data?.commission ?? 0.0)
                                                vc.sourceValue = self.sourceValue
                                                vc.sourceConfig = sourceConfig
                                                var name = String()
                                                var surName = String()
                                                var lastName = String()
                                                for i in dataListTV ?? [] {
                                                    if i?.content?.isEmpty == false{
                                                    switch i?.name {
                                                    case "Фамилия получателя":
                                                            surName += (i?.content?[0])!
                                                    case "Имя получателя":
                                                            name += (i?.content?[0])!
                                                    case "Отчество получателя":
                                                            lastName += (i?.content?[0])!
                                                    default:
                                                        break
                                                    }
                                                    }
                                                    
                                                }
                                                vc.destinationValue = "\(surName )" + " " + "\(name)" + " " + "\(lastName)"  + "."
                                               
                                                vc.phone = ""
                                                vc.currencyLable = dataListTV?[4]?.content?[0]
                                                // conv data.amount
                                                vc.countryValue =  setCountry
                                                vc.numberTransferValue = data[0]?.data?.listInputs?[0].content?[0]
                                                vc.amountRurCurrently = maskSum(sum: data[0]?.data?.amount ?? 0.0 )
                                                self.continueButton.isEnabled = true
                                                self.continueButton.alpha = 1
                                                dissmiss = true
                                                self.present(vc, animated: true, completion: nil)
                                            }
        //                                    self.dataList?.append(contentsOf: (data[0]?.data?.listInputs)!)
                                            loaderEnd()
                                        } else {
                                            loaderEnd()
                                            AlertService.shared.show(title: "Ошибка", message: "\(errorMessage!)", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                                        }
                                    }
//                                    self.dataList?.append(contentsOf: (data[0]?.data?.listInputs)!)
//                                    loaderEnd()
                                } else {
                                    loaderEnd()
                                    AlertService.shared.show(title: "Ошибка", message: "\(errorMessage!)", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                                }
                            }
                            
                            refreshView.isHidden = true
//                            loaderEnd()
                        } else {
                            loaderEnd()
                            AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                            errorLabel.text = errorMessage
//                            refreshView.isHidden = false
                        }
                    }
                } else {
                    loaderEnd()
                    AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                    errorLabel.text = errorMessage
//                    refreshView.isHidden = false

                }
            }
        } else {
                loaderTableView()
                self.parameters = setParameters()
                    NetworkManager.shared().getAnywayPaymentBegin(numberCard: getSourceValue(), puref: puref) { [self] (success, data, errorMessage) in
                        if success{
                            NetworkManager.shared().getAnywayPayment { [self] (success, data, errorMessage) in
                //                    data.filter({$0 ?.data?.listInputs?[0].readOnly == false})
                                if errorMessage == nil{
        //                            guard let dataList = data[0]?.data?.listInputs?.filter({ $0.readOnly == false }) else { return}
        //                            self.dataList = dataList
                //                    dataList = data[0]?.data?.listInputs?.filter({$0.readOnly == false})
                                    NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: self.parameters) { [self] (success, data, errorMessage) in
                                        if success ?? false{
                                            if data[0]?.data?.finalStep == 1{
                                                guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "CodeVerificationStroyboard") as? RegistrationCodeVerificationViewController else {
                                                                         return
                                                                     }
//                                                vc.operationSum =   data[0]?.data?.amount
//                                                vc.commission = data[0]?.data?.commission
                                                vc.sourceValue = sourceValue
                                                vc.sourceConfig = sourceConfig
                                                self.present(vc, animated: true, completion: nil)
                                                firstTimeRequest = false

                                            }
                                            self.dataList?.append(contentsOf: (data[0]?.data?.listInputs)!)
                                            loaderEnd()
                                            firstTimeRequest = false

                                        } else {
                                            loaderEnd()
                                            AlertService.shared.show(title: "Ошибка", message: "\(errorMessage!)", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                                            firstTimeRequest = false

                                        }
                                    }
                                } else {
                                    loaderEnd()
                //                    AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
//                                    errorLabel.text = errorMessage
//                                    refreshView.isHidden = false
//                                    firstTimeRequest = false

                                }
                            }
                        } else {
                            loaderEnd()
                //            AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
//                            errorLabel.text = errorMessage
//                            refreshView.isHidden = false
//                            firstTimeRequest = false

                        
                    }
                }
                firstTimeRequest = false
        }
    }
    
    @IBAction func amountTextField(_ sender: Any) {
//        setParameters()
    }
    func backFromDismiss(value: String?, key: String?, index: Int?, valueKey: String, fieldEmpty: Bool, segueId: String, listInputs: [ListInput?], parameters: [Additional]) {
        dataListTV?[index ?? 0]?.content?.removeAll()
        dataListTV?[index ?? 0]?.content?.append(valueKey)
        dataListTV?[index ?? 0]?.selectCountry = value
        dataList?[index ?? 0]?.content?.removeAll()
        dataList?[index ?? 0]?.content?.append(valueKey)
        dataList?[index ?? 0]?.selectCountry = value
        if segueId == "Валюта выдачи перевода"{
            let currency = getSymbol(forCurrencyCode: value ?? "RUB")
            if currency == "р."{
                CurrentlyLabel.setTitle("₽", for: .normal)
            } else {
                CurrentlyLabel.setTitle(currency, for: .normal)
            }
            setParameters()
        } else if segueId == "Страна выдачи перевода"{
//            dataListTV?[4]?.selectCountry = "Валюта выдачи перевода"
            setCountry = value
            setParameters()
            amountTextField.text = ""
            CurrentlyLabel.setTitle("", for: .normal)
//            continueButton.isEnabled = false
//            continueButton.alpha = 0.5
            tableView.reloadData()
        } else {
            parametersList.append(contentsOf: parameters)
            dataList = listInputs
            setCountry = value
            idCountry = key
            
        }
        for i in dataListTV ?? [] {
            if i?.content?.isEmpty == false{
                continueButton.isUserInteractionEnabled = true
                continueButton.alpha = 1
                continueButton.isEnabled = true
            } else {
                continueButton.isUserInteractionEnabled = false
                continueButton.alpha = 0.5
                continueButton.isEnabled = false
                break
            }
        }
//        continueButton.isEnabled = true
//        continueButton.isUserInteractionEnabled = true
//        continueButton.alpha = 1
        
        tableView.reloadData()
    }
    func onUserAction(value: String?, key: String?) {
        
        
    }
    var firstTimeRequestSourceView: Bool?
    
    func setConnectionWithService(){
        firstTimeRequestSourceView = false
        refreshView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimation()
        dataList?.removeAll()

    NetworkManager.shared().getAnywayPaymentBegin(numberCard: getSourceValue(), puref: puref) { [self] (success, data, errorMessage) in
        if success{
            NetworkManager.shared().getAnywayPayment { [self] (success, data, errorMessage) in
//                    data.filter({$0 ?.data?.listInputs?[0].readOnly == false})
                if errorMessage == nil{
                    guard let dataList = data[0]?.data?.listInputs?.filter({ $0.readOnly == false }) else { return}
                    self.dataList = dataList
//                    dataList = data[0]?.data?.listInputs?.filter({$0.readOnly == false})
                    refreshView.isHidden = true
                    loaderEnd()
                } else {
                    loaderEnd()
//                    AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                    errorLabel.text = errorMessage
                    refreshView.isHidden = true
                }
            }
        } else {
            loaderEnd()
//            AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
            errorLabel.text = errorMessage
            refreshView.isHidden = true

        }
    }
}
//            currentCode.text = getSymbol(forCurrencyCode: sourceValue?.currencyCode ?? "RUB")


}



extension ContactViewController: UITableViewDataSource, UITableViewDelegate{
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataListTV?.count == 0{
            guard let data = dataListTV else {
                return 0
            }
            return 0
        } else {
            guard let data = dataListTV else {
                return 0
            }
        return dataListTV?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.titleLabel.text = dataListTV?[indexPath.row]?.name
        switch  dataListTV?[indexPath.row]?.type{
        case "Input":
            
            cell.textField.placeholder = "Введите данные"
            cell.fieldname = dataList?[indexPath.row]?.id
            cell.fieldid = indexPath.row
            cell.delegate = self
            let changeState = dataListTV?[indexPath.row]?.readOnly
            cell.isUserInteractionEnabled = !(changeState ?? false)
            if !(dataListTV?[indexPath.row]?.content?.isEmpty ?? false){
                cell.textField.text = dataListTV?[indexPath.row]?.content?[0]
            } else if dataListTV?[indexPath.row]?.content?.count == 0{
                cell.textField.text = ""
            }
            return cell
        case "Select":
            cell.textField.isHidden = true
            cell.selectCountry.isHidden = false
            cell.delegate = self
//            CurrentlyLabel.setTitle(getSymbol(forCurrencyCode: ), for: .normal)
            if  dataListTV?[indexPath.row]?.content?.count ?? 0 == 0{
//                cell.textField.text = dataListTV?[indexPath.row]?.name
                cell.selectCountry.setTitle(dataListTV?[indexPath.row]?.name, for: .normal)
                
            } else {
                cell.selectCountry.setTitle(dataListTV?[indexPath.row]?.selectCountry, for: .normal)
                cell.selectCountry.isEnabled = true
//                cell.selectCountry.isUserInteractionEnabled = true
                
            }
            cell.fieldname = dataListTV?[indexPath.row]?.id
            cell.dataList = dataListTV?[indexPath.row]
            cell.fieldid = indexPath.row
            self.parameters = setParameters()
            self.dataSelect = dataListTV?[indexPath.row]?.dataType
            cell.isUserInteractionEnabled = true
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ContactViewController: ContactTableViewCellDelegate{

    
        func clearInputs(refresh: Bool) {
            self.amountTextField.text = ""
        }
    
   
    func didOpenSearchList(index: Int?) {

        guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ListOperationViewController") as? ListOperationViewController else {
                                 return
                             }
        vc.segueId = index
        vc.titleText = dataListTV?[index!]?.name
        vc.listInput = dataList?[index ?? 0]
        vc.puref = puref
        vc.lastParameters = parametersList
        vc.variableTransferValue = getSourceValue()
        vc.mainViewController = self
        present(vc, animated: true, completion:  nil)
    }
    func didChangeEnd(fieldName: String?, index: Int?,value: String?) {
        parameters?.removeAll()
        self.dataListTV?[index ?? 0]?.content?.removeAll()
        self.params = try? ParametrField(fieldName: fieldName!, fieldId: index!, fieldValue: value!)
        self.dataListTV?[index ?? 0]?.content?.append(value ?? "")
        self.dataList?[index ?? 0]?.content?.removeAll()
        self.params = try? ParametrField(fieldName: fieldName!, fieldId: index!, fieldValue: value!)
        self.dataList?[index ?? 0]?.content?.append(value ?? "")
        self.parameters = setParameters()
    }
    
    func didTapOnButton(_ list: ListInput?, index: Int?, data: ListInput?) {
        guard let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ListOperationViewController") as? ListOperationViewController else {
                                 return
                             }
        vc.mainViewController = self
        vc.titleText = data?.name
        let data = data?.dataType?.dropFirst(2).components(separatedBy: ";")
        let country = data?.map({$0.components(separatedBy: "=")})
        vc.listArray = country
        vc.segueId = index
        present(vc, animated: true, completion:  nil)
    }
    
}


extension ContactViewController: ICellConfiguratorDelegate{
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
                if let sourceConfig = sourceConfigurations?.filter({ $0 == configurator }).first {
                    switch (sourceConfig, value) {
                    case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                        firstTimeRequest = true
                        delegate?.didChangeSource(paymentOption: .option(destinationOption))
                      
                        break
                    default:
                        
                        break
                    }
                    
                    self.sourceConfig = sourceConfig
                    self.sourceValue = value as? PaymentOption
                    setConnectionWithService()
                }
            }
}

extension ContactViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
}

extension Sequence {
    public func toDictionary<Key: Hashable>(with selectKey: (Iterator.Element) -> Key) -> [Key:Iterator.Element] {
        var dict: [Key:Iterator.Element] = [:]
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}


extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}
