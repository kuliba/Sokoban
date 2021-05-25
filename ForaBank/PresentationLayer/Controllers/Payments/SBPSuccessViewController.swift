//
//  SBPSuccessViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.04.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SBPSuccessViewController: UIViewController, UINavigationBarDelegate {

    @IBOutlet weak var sbpLogo: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var number: UILabel!
//    @IBOutlet weak var name: UILabel!
//    @IBOutlet weak var bank: UILabel!
//    @IBOutlet weak var receiver: UILabel!
//
    @IBOutlet weak var codeRepeat: UIButton!
    //    @IBOutlet weak var amount: UILabel!
//    @IBOutlet weak var sbplogo: UIImageView!
//    @IBOutlet weak var successIcon: UIImageView!
    @IBOutlet weak var confirmButton: ButtonRounded!
//    @IBOutlet weak var confirmLabel: UILabel!
//    @IBOutlet weak var successLogo: UIImageView!
//    @IBOutlet weak var clockLogo: UIImageView!
    @IBOutlet weak var preloadView: UIView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView?
//    @IBOutlet weak var SBPtextLabel: UILabel!
//    @IBOutlet weak var checkPaymentCode: RoundedEdgeView!
    @IBOutlet weak var codeTextFiel: CustomTextField!
//    @IBOutlet weak var CodeLabel: UILabel!
//    @IBOutlet weak var commission: UILabel!
    @IBOutlet weak var codeTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeView: UIView!
    var delegate = SBPViewController()
//    weak var weakvalue = MainVC()
    var listInputs: [ListInput]? = []
    var listInputsFiltered: [ListInput]? = []
    var commissionText: String?
    var receiverPass: String?
    var summ = Double()
    var bankImage: UIImage?
    var bankOfPayeer = "Промсвязьбанк"
    var numberOfPayeer = "+7 (962) 612-92-68"
    var detailInformation = false
    
    var countTimer:Timer!
    var counter = 60
    
    @objc func changeTitle(){
         if counter != 0 {
             codeRepeat.setTitle(" 00: \(counter)", for: .normal)
             counter -= 1
            codeRepeat.tintColor = .red
            codeRepeat.titleLabel?.textColor = .red
            codeRepeat.backgroundColor = .clear
            codeRepeat.isEnabled = false
//            codeRepeat.titleLabel?.font =  UIFont(name: "Roboto", size: 12)

         } else {
            countTimer.invalidate()
            codeRepeat.backgroundColor = .gray
            codeRepeat.tintColor = .black
            codeRepeat.titleLabel?.textColor = .black
            codeRepeat.isEnabled = true
            codeRepeat.setTitle("Запросить код", for: .normal)
            codeRepeat.widthConstaint?.constant = 109
            codeRepeat.heightConstaint?.constant = 24
            
            codeRepeat.frame.size = CGSize(width: 109, height: 24)
            
//            codeRepeat.titleLabel?.font =  UIFont(name: "Roboto", size: 12)
        
         }
    }
    
    @IBAction func codeRepeatAction(_ sender: UIButton) {
        NetworkManager.shared().getVerificationCode { [self] success, errorMessage in
            if success ?? false{
                counter = 60
                self.countTimer = Timer.scheduledTimer(timeInterval: 1 ,
                                                             target: self,
                                                             selector: #selector(changeTitle),
                                                             userInfo: nil,
                                                             repeats: true)
            } else {
                codeRepeat.isHidden = true
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        codeRepeat.backgroundColor = .clear
//        codeRepeat.tintColor = .red
//  
//        self.countTimer = Timer.scheduledTimer(timeInterval: 1 ,
//                                                     target: self,
//                                                     selector: #selector(changeTitle),
//                                                     userInfo: nil,
//                                                     repeats: true)

     
        
        codeTextField.backgroundColor = .white
        if detailInformation{
            listInputsFiltered = listInputs?.filter({$0.content?.count != 0 || $0.name != "Валюта перевода" || $0.name != "БИК получателя перевода"})
            tableView.heightConstaint?.constant = CGFloat(listInputsFiltered!.count * 70)
            titleLabel.text = "Детали операции"
            sbpLogo.isHidden = true
            if #available(iOS 13.0, *) {
                backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
                backButton.tintColor = .black
            } else {
                // Fallback on earlier versions
            }
            confirmButton.isHidden = true
            codeView.isHidden = true
        } else {
        listInputsFiltered = listInputs?.filter({$0.name == "Телефон получателя" || $0.name == "Сумма перевода" || $0.name == "Получатель перевода" || $0.name == "Банк получателя перевода" })
        listInputsFiltered?.append(ListInput(content: nil, dataType: nil, hint: nil, id: nil, mask: nil, max: nil, min: nil, name: "Комиссия", note: nil, onChange: nil, order: nil, paramGroup: nil, print: nil, readOnly: nil, regExp: nil, req: nil, rightNum: nil, sum: nil, template: nil, type: nil, visible: nil, selectCountry: ""))
    }
        tableView.delegate = self
        tableView.register(UINib(nibName: "ConfirmPaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "ConfirmPaymentTableViewCell")
//        checkPaymentCode.isHidden = true
//        commission.text = commissionText
//        receiver.text = receiverPass
//        amount.text = "\(maskSum(sum: summ)) ₽"
//        bank.text = bankOfPayeer
//        let dropFirstNumber = numberOfPayeer.dropFirst()
//        number.text = formattedNumberInPhoneContacts(number: String(dropFirstNumber))
//        successIcon.isHidden = true
//        successLogo.isHidden = true
//        clockLogo.isHidden = true
//        confirmButton.backgroundColor = .clear
//        confirmButton.layer.borderWidth = 1
//        confirmButton.layer.borderColor = UIColor.white.cgColor
        
    }
    
    @IBAction func editingChange(_ sender: Any) {
        if codeTextField.text?.count == 6 {
            confirmButton.backgroundColor = UIColor(hexFromString: "#FF3636")
            confirmButton.isEnabled = true
        } else {
            confirmButton.backgroundColor = UIColor(hexFromString: "#D3D3D3")
            confirmButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? SuccessPaymentViewController
//        vc?.amountLabel.text = String(summ) + "₽"
//        vc?.recipientLabel.text = receiverPass
//        vc?.idPayment.text = listInputs?[7].content?[0]
//        vc?.typeLabel.text = bankOfPayeer
        vc?.listInputs = listInputs
        
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func confirmInfo(_ sender: Any) {
//        dataLoad()
        if confirmButton.titleLabel?.text == "Перевести", codeTextField.text != "" {
            preloadView.isHidden = false
            activityIndicator?.startAnimation()
            NetworkManager.shared().anywayPaymentMake(code: "\(codeTextField.text ?? "")") { (success, errorMessage) in
                if success {
//                    self.successIcon.isHidden = false
//                    self.sbplogo.isHidden = true
            //        clockLogo.isHidden = false
//                    self.SBPtextLabel.isHidden = true
//                    self.successLogo.isHidden = false
//                    self.successIcon.isHidden = false
//                    self.clockLogo.isHidden = true
//                    self.codeTextFiel.isHidden = true
//                    self.CodeLabel.isHidden = true
//                    self.successIcon.isHidden = true
//                    self.confirmButton.setTitle("На главную", for: .normal)
//                    self.confirmLabel.text = "Успешный перевод!"
//                    self.confirmLabel.textColor = .white
                    self.performSegue(withIdentifier: "finish", sender: nil)
                } else {
                    AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                }
                self.preloadView.isHidden = true
                self.activityIndicator?.stopAnimating()
            }
        } else {
            delegate.reloadData()
            delegate.reloadInputViews()
            dismiss(animated: true)
            print("Hello")
        }
    }
    func dismissToRootViewController() {
         if let first = presentingViewController,
             let second = first.presentingViewController,
             let third = second.presentingViewController {

             first.view.isHidden = true
             second.view.isHidden = true
             third.dismiss(animated: false)
            dismissToRootViewController()
         }
        dismiss(animated: true, completion: nil)
     }
    func dataLoad(){
        activityIndicator?.startAnimation()
        activityIndicator?.isHidden = false
        preloadView.isHidden = false
    
    }
    @IBAction func dissmissButton(_ sender: Any) {
        if let first = presentingViewController,
            let second = first.presentingViewController,
            let third = second.presentingViewController {

            first.view.isHidden = true
            second.view.isHidden = true
            third.dismiss(animated: false)
            dismissToRootViewController()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SBPSuccessViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listInputsFiltered?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmPaymentTableViewCell") as? ConfirmPaymentTableViewCell
        cell?.titleLabel.text = listInputsFiltered?[indexPath.row].name
       
        if listInputs?[indexPath.row].content?.count ?? 0 > 0{
            cell?.subtitleLabel.text = listInputs?[indexPath.row].content?[0]
        } else {
            cell?.subtitleLabel.text = ""
        }
        
        switch listInputsFiltered?[indexPath.row].name {

        case "Телефон получателя":
            cell?.iconImageView?.image = UIImage(named: "mobileWithBorder")
            cell?.subtitleLabel.text = formattedPhoneNumber(number: "\("+7" + (listInputsFiltered?[indexPath.row].content?[0])!)")
        case "Сумма перевода":
            cell?.iconImageView?.image = UIImage(named: "coins")
            cell?.subtitleLabel.text = "\( listInputsFiltered?[indexPath.row].content?[0] ?? "") ₽"
        case "Получатель перевода":
            cell?.iconImageView?.image = UIImage(named: "userIcon")
            cell?.subtitleLabel.text = listInputsFiltered?[indexPath.row].content?[0]
        case "Банк получателя перевода":
            cell?.iconImageView?.image = UIImage(named: "bank_icon")
            cell?.subtitleLabel.text = listInputsFiltered?[indexPath.row].content?[0]
            cell?.bankImageView.image = bankImage
        case "Комиссия":
            cell?.iconImageView?.image = UIImage(named: "procent")
            cell?.subtitleLabel.text = commissionText
        case "Идентификатор операции ОПКЦ СБП":
            cell?.iconImageView.image = UIImage(named: "hash")
            cell?.subtitleLabel.text = listInputsFiltered?[indexPath.row].content?[0]
        default:
            break
        }
        return cell!
    }
    
    
}
