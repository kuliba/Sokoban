//
//  FreeDetailsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 09.01.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import ReSwift
import Alamofire
import IQKeyboardManagerSwift
import UBottomSheet
//import OverlayContainer


protocol SPBViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType)
    func didChangeDestination(paymentOption: PaymentOptionType)
    
    func didChangeAmount(amount: Double?)

    func didPressPrepareButton()
    func didPressPaymentButton()
}


class SBPViewController: UIViewController, UITextFieldDelegate, FirstViewControllerDelegate, ModalViewControllerDelegate, StoreSubscriber, PaymentDetailsPresenterDelegate, UITextViewDelegate, UIViewControllerTransitioningDelegate{
 
    
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var defaultBankLabel: UILabel!
    var dataInputList = [AnywayPaymentInputs?]()
    var fio = ""
    var fullCircle: Bool?
    var numberCard: String?
    var circleView = UIView()
    public func toDouble() -> Double? {
        return NumberFormatter().number(from: amountTextField.text ?? "0")?.doubleValue
     }
   
//    func completionPayment(countField: Int?, filled: Bool?) -> Bool{
//        sourceValue, destinationValue, idDefaultBank != ""
//    }
//
    func addCircleView() {
        circleView.frame = CGRect(x: 0, y: 0, width: view.frame.width * 5, height: view.frame.width * 5)
        circleView.center = view.center
        circleView.frame.origin.y = UIDevice.hasNotchedDisplay ? 90 : 67
        circleView.backgroundColor = .clear
        let layer = CAShapeLayer()
        layer.path = CGPath(ellipseIn: circleView.bounds, transform: nil)
        layer.fillColor = UIColor.white.cgColor
        circleView.layer.addSublayer(layer)
        circleView.clipsToBounds = true
        view.insertSubview(circleView, at: 1)
    }
    
    @IBAction func amountValueChanged(_ sender: UITextField) {
        amountTextField.text = maskSum(sum: toDouble() ?? 0.0)
    }
    
    
    @IBAction func paymentSBP(_ sender: Any) {
        if Double(minSum ?? Int(0.0)) ... Double(maxSum ?? Int(0.0)) ~= Double((amountTextField.text)?.replace(string: ",", replacement: ".") ?? "0") ?? 0.0 {
        indicatorView.isHidden = false
        activityIndicatorView.startAnimation()
            
            switch self.fullCircle {
            case true:
                print("FullCircle")
                var variableTransferValue = String()
                if sourceValue?.number.count ?? 0 > 17{
                    guard let sourceVariable = sourceValue?.id else {
                        return
                    }
                    variableTransferValue = "\(String(sourceVariable).dropLast(2))"
                    self.numberCard = "\(String(sourceVariable).dropLast(2))"
                } else {
                    variableTransferValue = "\(cardNumber)"
                    self.numberCard = "\(cardNumber)"

                }
                NetworkManager.shared().getAnywayPaymentBegin(numberCard: "\(variableTransferValue)", puref: "iFora||TransferC2CSTEP") { (success,     anywayPaymentBegin, errorMessage) in
                    if success {
                        self.selectBankView.isHidden = false
                        self.indicatorView.isHidden = false
                        self.activityIndicatorView.startAnimation()
                NetworkManager.shared().getAnywayPayment{ (success, anywayPaymentModel, errorMessage) in
                        if success ?? false{
                            NetworkManager.shared().getAnywayPaymentFinal(memberId: self.memberId, amount: "0", numberPhone: self.destinationValue as? String, parameters: nil) { [self] (success, anywayPaymentInput, errorMessage) in
                                if anywayPaymentInput[0]?.result != "ERROR"{

                                    NetworkManager.shared().getAnywayPaymentFinal(memberId: self.memberId ,amount: (self.amountTextField.text)?.replace(string: ",", replacement: "."), numberPhone: self.destinationValue as? String, parameters: nil) { [self] (success, anywayPaymentInput, errorMessage) in
                                                    if errorMessage == nil{
                                                        
                                //                                        guard let memberIdBank = memberId else {return}
                                                                            self.dataInputList = anywayPaymentInput
                                                                        let vc =  storyboard?.instantiateViewController(withIdentifier: "SBPSuccessViewController") as? SBPSuccessViewController
                                //                                            anywayPaymentInput[0]?.data?.commission
                                //                                            let amountWithSum = Double(amountTextField.text) + anywayPaymentInput[0]?.data?.commission
                                                                            
                                                                guard let receiver = anywayPaymentInput[0]?.data?.listInputs?[5].content?[0] else {
                                                                            return
                                                                            }
                                                                            guard let commission = anywayPaymentInput[0]?.data?.commission else {
                                                                                return
                                                                            }
                                                                        vc?.commissionText = "Комиссия \(String(describing: commission)) ₽"
                                                                        vc?.receiverPass = "\(receiver)"
                                                                        vc?.summ = toDouble() ?? 0
                                                                        vc?.bankOfPayeer = nameOfBank.text!
                                                                        vc?.numberOfPayeer = destinationValue as! String
                                                                        present(vc!, animated: true, completion: nil)
                                                                            self.indicatorView.isHidden = true
                                                                            self.activityIndicator.stopAnimating()
                                                                        } else {
                                                                            let alert = UIAlertController(title: "Ошибка", message: "\(errorMessage!)", preferredStyle: .alert)
                                                                            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                                                                                // обработка нажатия кнопки
                                                                            })
                                //                                            indicatorView.isHidden = true
                                //                                            activityIndicator.stopAnimating()
                                                                            self.indicatorView.isHidden = true
                                                                            self.activityIndicator.stopAnimating()
                                                                            
                                                                            self.present(alert, animated: true, completion: nil)
                                                                        }
                                                                    }
                                 
                            } else{
                                AlertService.shared.show(title: "Ошибка", message: "\(errorMessage ?? "Повторите позднее")", cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil   )
                                self.indicatorView.isHidden = true
                                self.activityIndicatorView.stopAnimating()
                            }
                        }
                    } else {
                        print("Error")
                        self.indicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    }
                }
                    }
                    else{
                        AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil   )
                        self.indicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    }
                    
                }
                
            default:
                
                var variableTransferValue = String()
                if sourceValue?.number.count ?? 0 > 17{
                    guard let sourceVariable = sourceValue?.id else {
                        return
                    }
                    variableTransferValue = "\(String(sourceVariable).dropLast(2))"
                    self.numberCard = "\(String(sourceVariable).dropLast(2))"
                } else {
                    variableTransferValue = "\(cardNumber)"
                    self.numberCard = "\(cardNumber)"

                }
                self.fullCircle = true
                print("FullCircle")
                NetworkManager.shared().getAnywayPaymentBegin(numberCard: "\(variableTransferValue)", puref: "iFora||TransferC2CSTEP") { (success,     anywayPaymentBegin, errorMessage) in
                    if success {
                        self.selectBankView.isHidden = false
                        self.indicatorView.isHidden = false
                        self.activityIndicatorView.startAnimation()
                NetworkManager.shared().getAnywayPayment{ (success, anywayPaymentModel, errorMessage) in
                        if success ?? false{
                            NetworkManager.shared().getAnywayPaymentFinal(memberId: self.memberId, amount: "0", numberPhone: self.destinationValue as? String, parameters: nil) { [self] (success, anywayPaymentInput, errorMessage) in
                                if anywayPaymentInput[0]?.result != "ERROR"{

                                        NetworkManager.shared().getAnywayPaymentFinal(memberId: self.memberId ,amount: (self.amountTextField.text)?.replace(string: ",", replacement: "."), numberPhone: self.destinationValue as? String, parameters: nil) { [self] (success, anywayPaymentInput, errorMessage) in
                                                    if errorMessage == nil{
                                                        
                                //                                        guard let memberIdBank = memberId else {return}
                                                                            self.dataInputList = anywayPaymentInput
                                                                        let vc =  storyboard?.instantiateViewController(withIdentifier: "SBPSuccessViewController") as? SBPSuccessViewController
                                //                                            anywayPaymentInput[0]?.data?.commission
                                //                                            let amountWithSum = Double(amountTextField.text) + anywayPaymentInput[0]?.data?.commission
                                                                            
                                                                guard let receiver = anywayPaymentInput[0]?.data?.listInputs?[5].content?[0] else {
                                                                            return
                                                                            }
                                                                            guard let commission = anywayPaymentInput[0]?.data?.commission else {
                                                                                return
                                                                            }
                                                                        vc?.commissionText = " \(String(describing: commission)) ₽"
                                                                        vc?.receiverPass = "\(receiver)"
                                                                        vc?.summ = toDouble() ?? 0
                                                                        vc?.bankOfPayeer = nameOfBank.text!
                                                                        vc?.bankImage = self.bankImage.image ?? nil
                                                                        vc?.numberOfPayeer = destinationValue as! String
                                                        vc?.listInputs = anywayPaymentInput[0]?.data?.listInputs
                                                                        present(vc!, animated: true, completion: nil)
                                                                            self.indicatorView.isHidden = true
                                                                            self.activityIndicator.stopAnimating()
                                                                        } else {
                                                                            let alert = UIAlertController(title: "Ошибка", message: "\(errorMessage ?? "Ошибка")", preferredStyle: .alert)
                                                                            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                                                                                // обработка нажатия кнопки
                                                                            })
                                //                                            indicatorView.isHidden = true
                                //                                            activityIndicator.stopAnimating()
                                                                            self.indicatorView.isHidden = true
                                                                            self.activityIndicator.stopAnimating()
                                                                            
                                                                            self.present(alert, animated: true, completion: nil)
                                                                        }
                                                                    }
                                 
                            } else{
                                AlertService.shared.show(title: "Ошибка", message: "\(errorMessage ?? "Повторите позднее")", cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil   )
                                self.indicatorView.isHidden = true
                                self.activityIndicatorView.stopAnimating()
                            }
                        }
                    } else {
                        print("Error")
                        self.indicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    }
                }
                    }
                    else{
                        AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil   )
                        self.indicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    }
                    
                }
                        }
            } else {
                let alert = UIAlertController(title: "Ошибка" , message: "Сумма Операции СБП должна быть больше \(minSum ?? 0) рублей и меньше \(maxSum ?? 0) рублей", preferredStyle: .alert)
                                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)

                                    
                                }
                            }
    
    
    @IBOutlet weak var indicatorView: UIView!
//    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    
    @IBOutlet weak var sourcePagerView: PagerView!
    @IBOutlet weak var destinationPagerView: PagerView!

    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var paymentCompany: ButtonRounded!
    
    @IBOutlet weak var dataPaymentSbp: UIView!
    @IBOutlet weak var comment: CustomTextField!
    @IBOutlet weak var roundedEdgeText: RoundedEdgeView!
    @IBOutlet weak var bankImage: UIImageView!
    
    @IBOutlet weak var currencyCodeLabel: UILabel!
    // outlets select bank
    
    @IBOutlet weak var messageRecipientView: UIView!
    @IBOutlet weak var messageRecipient: UITextView!
    @IBOutlet weak var accountNumberNon: UILabel!
    
    @IBOutlet weak var containterView: RoundedEdgeView!
    
    @IBOutlet weak var dataStackView: UIStackView!
    @IBOutlet weak var dropDownImage: UIImageView!
    @IBOutlet weak var nameOfBank: UILabel!
    var memberId = ""
    @IBOutlet weak var star: UIImageView!
    @IBOutlet weak var beforeAddNumber: UIView!
    
    @IBOutlet weak var roundedEdgeView: RoundedEdgeView!
    @IBOutlet weak var selectBankView: UIView!
    var idDefaultBank = ""
    var defaultBank: [BLDatum?] = []
    var bankList:BLBankList?
    var bankName = String()
    var sourceValue: PaymentOption?{
        didSet{
            
        }
    }
    var maxSum: Int?
    var minSum: Int?
    var presenter: PaymentDetailsPresenter?
    var sourceConfigurations: [ICellConfigurator]?
    var destinationConfigurations: [ICellConfigurator]?
    var delegate: PaymentsDetailsViewControllerDelegate?
    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var sourceConfig: Any? {
        didSet{
            
        }
    }
    var destinationConfig: Any?
    var destinationValue: Any?
    var cards = [BankSuggest]()
    var scrollView: UIScrollView!
    var newName: String? = nil
    var id: String? = nil
    var comissions: Double = 10.0
    var numberPayeer: String = ""
    var cardNumber = String()
    var numberPhone = String()
    
    
    @IBOutlet weak var activityIndicatorView: ActivityIndicatorView!
    func didPrepareData(data: DataClassPayment?) {
        
    }
    
    func didFinishPreparation(success: Bool, data: DataClassPayment?) {
        if success {
            performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
            
            
            
        } else {
            AlertService.shared.show(title: "Ошибка", message: "При выполнении платежа произошла ошибка, попробуйте ещё раз позже", cancelButtonTitle: "Продолжить", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
        }
    }

    
 

    
    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool) {
        print(isLoading, canAskFee, canMakePayment)
//        paymentCompany.changeEnabled(isEnabled: canAskFee)
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    func sendValue(_ value: String?, _ image: String?, _ backgroundColor: String?, memberId: String?, defaultBank: Bool?) {
        self.dismiss(animated: true) { [self] in
                self.nameOfBank.text = value
                bankLabel.isHidden = false
                self.memberId = memberId ?? ""
                bankImage.isHidden = false
                nameOfBank.textColor = UIColor(named: "#1C1C1C")
                self.bankImage.image = UIImage(named: "\(image ?? "nil")")
                self.bankImage.layer.cornerRadius = self.bankImage.frame.size.width/2
                self.bankImage.backgroundColor = UIColor(hexFromString: "\(backgroundColor ?? "#123432")")
                if self.defaultBank.count > 0, memberId == self.defaultBank[0]?.id{
                    self.star.isHidden = false
                    self.memberId = memberId ?? ""
                    self.defaultBankLabel.isHidden = false
                } else {
//                    self.star.isHidden = true
//                    self.defaultBankLabel.isHidden = true
                }
              }
     }
    
    func update(text: Double) {
        comissions = 30.0
    }
//
//    func displayActivityLikeViewController() {
//        let container = OverlayContainerViewController()
//        container.viewControllers = [ProductListSheetsViewController()]
//        container.transitioningDelegate = self
//        container.modalPresentationStyle = .custom
//        present(container, animated: true, completion: nil)
//    }
//
//    // MARK: - UIViewControllerTransitioningDelegate
//
//    func presentationController(forPresented presented: UIViewController,
//                                presenting: UIViewController?,
//                                source: UIViewController) -> UIPresentationController? {
//        return OverlayContainerSheetPresentationController(
//            presentedViewController: presented,
//            presenting: presenting
//        )
//    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        if segue.identifier == "searchBank"{
            
            

//            let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ProductListSheetsViewController") as! ProductListSheetsViewController
//            present(vc, animated: true, completion: nil)
            
            let searchBankVC = segue.destination as? SearchBanksViewController
            searchBankVC?.idDefaultBank = idDefaultBank
            searchBankVC?.delegate = self
        } else {
            if amountTextField.text == "0", Int(amountTextField.text ?? "0") ?? 0 >= 600000{
                                let alert = UIAlertController(title: "Сумма Операции СБП должна быть больше 10 рублей и меньше 600 000 рублей", message: "", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)

                                
                            } else if nameOfBank.text == "Выберите банк получателя"{
                let alert = UIAlertController(title: "Заполните все поля", message: "", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                           
                           self.present(alert, animated: true, completion: nil)
            } else {
                print("No segue")
            }
            
          
            
        }
    }
    
    

    

    
    

    @IBAction func segueButton(_ sender: Any) {
        let controller = SearchBanksViewController()
            controller.delegate = self
                  performSegue(withIdentifier: "searchBank", sender: Any?.self)
                  self.present(controller, animated: true, completion: nil)
    
      

    }

    //end outlets
    @IBAction func amountTextFieldValueChanged(_ sender: Any) {
        delegate?.didChangeAmount(amount: Double(amountTextField.text!.replacingOccurrences(of: ",", with: ".")))
//        let dotString = "."
//        var maxLength = 9
//        if (amountTextField.text?.contains(dotString))! {
//                maxLength = 12
//        }
        
        
            if let amountDoubleType = Double(amountTextField.text! + ".00") {
                if amountDoubleType >  (sourceValue)?.value ?? 0.0 || amountDoubleType <= 10{
                    paymentCompany.changeEnabled(isEnabled: false)
            }
        }
       
    }
  
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientView() // TODO: Replace with GradientView view
    }
    
    
    @IBAction func didChangeNumberAccount(_ sender: Any) {
//        if numberAcoount.text = "444"{
//
//        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }
 
    


    
     internal func newState(state: ProductState) {
            //optionsTable.reloadData()
    //        setUpRemittanceViews()
        }
    

    
    

    

    
    private let destinationProviderCardNumber = CardNumberCellProvider()
  private let destinationProviderAccountNumber = AccountNumberCellProvider()
  private let destinationProviderPhoneNumber = PhoneNumberCellProvider()

    weak var delegateBlock: PaymentOptionsState?
    let placeHolderMessageRecipient = "Сообщение получателю"
     let colorBorderMessageRecipient = UIColor.systemGray.withAlphaComponent(0.5).cgColor
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(false)
//            _ = amountTextField.becomeFirstResponder()
        sourcePagerView.setConfig(config: sourceConfigurations ?? [])
    }
    func reloadData(){
//        sourcePagerView.setConfig(config: sourceConfigurations ?? [])
//        destinationPagerView.pagerView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bankLabel.isHidden = true
        amountTextField.backgroundColor = .white
        messageRecipientView.backgroundColor = .white
        
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
        paymentCompany.changeEnabled(isEnabled: false)
//        paymentCompany.isEnabled = false
        navigationItem.largeTitleDisplayMode = .always
        delegateBlock?.state(true)
//        dataStackView.removeArrangedSubview(selectBankView)
//        selectBankView.removeFromSuperview()
//            selectBankView.isHidden = false
//        roundedEdgeView.translatesAutoresizingMaskIntoConstraints = false
//        selectBankView.frame.size.height = 0
//        dataStackView.removeArrangedSubview(selectBankView)
//        selectBankView.isHidden = true
        indicatorView.isHidden = false
        indicatorView.addSubview(activityIndicator)
        activityIndicator.center = indicatorView.center
        activityIndicatorView.startAnimation()
        
        amountTextField.delegate = self
//        messageRecipient.textColor = UIColor.lightGray
//        nameOfBank.text = bankName
        // Do any additional setup after loading the view.
//        self.messageRecipient.delegate = self
//        self.messageRecipient.layer.cornerRadius = 5.0
//        self.messageRecipient.layer.borderColor = colorBorderMessageRecipient
//        self.messageRecipient.text = self.placeHolderMessageRecipient
//        self.messageRecipient.layer.borderColor = UIColor.red.cgColor
//        self.messageRecipient.textColor = UIColor.systemGray

     
        
        
        amountTextField.delegate = self
        paymentCompany.alpha = 0.5
        paymentCompany.isEnabled = false
        
             if let source = sourceConfigurations, let dest = destinationConfigurations {
                self.sourcePagerView.currentBlock = true
                   sourcePagerView.setConfig(config: source)
                    destinationPagerView.setConfig(config: dest)
               }


        
    
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
         self.messageRecipient.layer.borderWidth = 1
         //place Holder Message Recipient off
         if self.messageRecipient.text == self.placeHolderMessageRecipient{
             self.messageRecipient.text = ""
             self.messageRecipient.textColor = .black
         }
     }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.messageRecipient.layer.borderWidth = 0
        //place Holder Message Recipient on
        if self.messageRecipient.text == ""{
            self.messageRecipient.text = self.placeHolderMessageRecipient
            self.messageRecipient.textColor = .systemGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 210    // 210 Limit Value
    }
    
    // изменяем textView под размер тексте
    func textViewDidChange(_ textView: UITextView) {
        if textView.numberOfLines() == 1{ //если первая строка
            if self.messageRecipient.heightConstaint?.constant == 70{ //если перешли с 2 на 1 строку
                self.messageRecipient.heightConstaint?.constant = 40 //ставим обычный рамер
            }
        }else if textView.numberOfLines() == 2{ // если вторая строка
            self.messageRecipient.heightConstaint?.constant = 70 // увеличиваем размер textView
        }
    }


   
    
    let taskTextFieldlimitLength = 11

     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         let dotString = ","
         //let characters = ""
         var maxLength = 9
         if (textField.text?.contains(dotString))! {
             maxLength = 12
         }
         if string == ","{
             textField.text = textField.text! + ","
             maxLength = 12
         }
                 
         if let text = textField.text{
             textField.text = "\(text)"
             
             let isDeleteKey = string.isEmpty
             if !isDeleteKey {
                 if text.contains(dotString) {
                     if text.components(separatedBy: dotString)[1].count == 2 || string == ","  {
                      return false
                     }
                 }
             }
         }
        
        if textField.isEditing{
            paymentCompany.alpha = 1
            paymentCompany.isEnabled = true
            paymentCompany.backgroundColor = UIColor(hexFromString: "#FF3636")
        }
     guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= maxLength // replace 30 for your max length value
     }
    
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
}


private extension SBPViewController {
    private func setUpPicker() {
//        picker.layer.cornerRadius = 3
//        pickerImageView.image = pickerImageView.image?.withRenderingMode(.alwaysTemplate)
//        pickerImageView.tintColor = .white
    }

    private func addGradientView() {
        let containerGradientView = GradientView()
        containerGradientView.frame = containterView.frame
//        containerGradientView.color1 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
//        containerGradientView.color2 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }

    private func setUpLayout() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
    }
}









private var kAssociationKeyMaxLength: Int = 0



extension UIStackView {

    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }

}

extension SBPViewController: ICellConfiguratorDelegate {
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
//        self.sourceValue?.name = "Счет: " + "\(String(describing: (value as! PaymentOption).name))"
//        (value as? PaymentOption)?.name?.append("Счет: ")
        if let sourceConfig = sourceConfigurations?.filter({ $0 == configurator }).first {
            switch (sourceConfig, value) {
            case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                delegate?.didChangeSource(paymentOption: .option(destinationOption))
                indicatorView.isHidden = true
                break
            default:
//               (value as? PaymentOption)?.name?.append("Счет: ")
                break
            }
            self.sourceConfig = sourceConfig
//            self.sourceValue?.name = "Счет: " + "\(String(describing: (value as! PaymentOption).name))"
            self.sourceValue = value as? PaymentOption
            
            if let amountDoubleType = Double(amountTextField.text! + ".00") {
                if amountDoubleType >  (sourceValue)?.sum ?? 0.0 || amountDoubleType <= 10.0{
                    paymentCompany.changeEnabled(isEnabled: false)
                } else {
                    paymentCompany.changeEnabled(isEnabled: true)
                    paymentCompany.backgroundColor = UIColor(hexFromString: "#FF3636")
                }
        }
          
//            self.currencyCodeLabel.text = getSymbol(forCurrencyCode: (sourceValue)?.currencyCode ?? "RUB" )
//            (value as? PaymentOption)?.name = "Счет " + "\(String(describing: (value as! PaymentOption).name))"
            guard let numberCard = sourceValue?.number else {
                return
            }
            self.cardNumber = numberCard
        } else if let destinationConfig = destinationConfigurations?.filter({ $0 == configurator }).first {
            switch (destinationConfig, value) {
            case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                delegate?.didChangeDestination(paymentOption: .option(destinationOption))
                break
            case (is CardNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .cardNumber(destinationOption))
                break
            case (is PhoneNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .phoneNumber(destinationOption))
//                selectBankView.isHidden = true
                break
            case (is AccountNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .accountNumber(destinationOption))
                break
            default:
                break
            }
            self.destinationConfig = destinationConfig
            self.destinationValue = value
            
            if (value as! String).count == 11{
                self.view.endEditing(true)
                self.fullCircle = false
                self.resignFirstResponder()
//                nameOfBank.text = "Выберите банк получателя"
//                star.isHidden = true
//                defaultBankLabel.isHidden = true
//                bankImage.image = UIImage(named: "question")
                var variableTransferValue = String()
                if sourceValue?.number.count ?? 0 > 17{
                    guard let sourceVariable = sourceValue?.id else {
                        return
                    }
                    variableTransferValue = "\(String(sourceVariable).dropLast(2))"
                    self.numberCard = "\(String(sourceVariable).dropLast(2))"
                } else {
                    variableTransferValue = "\(cardNumber)"
                    self.numberCard = "\(cardNumber)"

                }
                NetworkManager.shared().getAnywayPaymentBegin(numberCard: "\(variableTransferValue)", puref: "iFora||TransferC2CSTEP") { (success,     anywayPaymentBegin, errorMessage) in
                    if success {
                        self.fullCircle = false
                        self.selectBankView.isHidden = false
                        self.indicatorView.isHidden = false
                        self.activityIndicatorView.startAnimation()
                NetworkManager.shared().getAnywayPayment{ (success, anywayPaymentModel, errorMessage) in
                        if success ?? false{
                            if anywayPaymentModel.count > 0 {
                            self.maxSum = anywayPaymentModel[0]?.data?.listInputs?[1].max
                            self.minSum = anywayPaymentModel[0]?.data?.listInputs?[1].min
                            }
                            NetworkManager.shared().getAnywayPaymentFinal(memberId: self.memberId, amount: "0", numberPhone: self.destinationValue as? String, parameters: nil) { [self] (success, anywayPaymentInput, errorMessage) in
                                if anywayPaymentInput[0]?.result != "ERROR"{
                                    let defaultBank = anywayPaymentInput[0]?.data?.listInputs?[0].content
                                    if defaultBank?.count ?? 0 > 0{
                                        idDefaultBank = defaultBank?[0] ?? ""
                                        self.memberId = defaultBank?[0] ?? ""
                                        
                                        NetworkManager.shared().findBankList { (success, bankList, errorMessage) in
                                            let defaultBank = bankList?.data?.filter {$0.id == defaultBank?[0]}
                                            self.defaultBank = defaultBank ?? []
                                            if anywayPaymentInput[0]?.data?.listInputs?[0].content?[0] == "100000000217" {
                                                
//                                                self.nameOfBank.text = "Фора-Банк"
//                                                self.bankImage.image = UIImage(named:"foralogotype")
//                                                defaultBankLabel.isHidden = false
//                                                star.isHidden = false
                                            } else {
                                            self.nameOfBank.text = self.defaultBank[0]?.memberNameRus
                                            guard let memberId = self.defaultBank[0]?.memberID else { return }
                                            self.bankImage.image = UIImage(named:"\(memberId)")
                                            self.memberId = self.defaultBank[0]?.id ?? ""
                                            defaultBankLabel.isHidden = false
                                            star.isHidden = false
                                            }
                                            
                                        }
                                        
                                        self.indicatorView.isHidden = true
                                        self.activityIndicatorView.stopAnimating()
                                    } else {
//                                        NetworkManager.shared().findBankList { (success, bankList, errorMessage) in
//                                            let defaultBank = bankList?.data?.filter {$0.id == defaultBank?[0]}
//                                            self.defaultBank = defaultBank ?? []
//                                        }
//                                        nameOfBank.text = self.defaultBank[0]?.memberNameRus
                                        nameOfBank.text = "Выберите банк получателя"
//                                        star.isHidden = true
//                                        defaultBankLabel.isHidden = true
//                                        bankImage.image = UIImage(named: "question")
                                        self.indicatorView.isHidden = true
                                        self.activityIndicatorView.stopAnimating()
                                    }
                            } else{
                                AlertService.shared.show(title: "Ошибка", message: "\(errorMessage ?? "Повторите позднее")", cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil   )
                                self.indicatorView.isHidden = true
                                self.activityIndicatorView.stopAnimating()
                            }
                        }
                    } else {
                        print("Error")
                        self.indicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    }
                }
                    }
                    else{
                        AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil   )
                        self.indicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                    }
                    
                }
                
                self.indicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
                
            } else {
                

            }
        }
    }
    
}



