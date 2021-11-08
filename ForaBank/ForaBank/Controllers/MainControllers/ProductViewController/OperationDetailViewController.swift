//
//  OperationDetailViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 01.11.2021.
//

import Foundation
import UIKit


class OperationDetailViewController: UIViewController{
    
    var operation: OperationDetailDatum?
    
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
//            confurmView.confurmVCModel = model
            
        }
    }
    
    var documentId = String()
    
    var stackView = UIStackView()
    
    var contactButtonStackView = UIStackView()
    
    var buttonStackView = UIStackView()

    let changeButton = UIButton()
    let returnButton = UIButton()

    
//    var closeButton: UIButton = {
//       let button = UIButton()
//        button.setImage(UIImage(named: "xmarknew"), for: .normal)
//        button.setDimensions(height: 24, width: 24)
//        return button
//    }()

    var transferImage = UIImageView()
    
    var mainLabel: UILabel  = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 1
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    var categoryGroupLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    
    
    var nameOperationLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var companyImage = UIImageView()
    
    var recipient: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var amount: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 24, weight: .bold), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    var commissionLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var commentView: UIView = {
        let view = UIView()
        view.setDimensions(height: 40, width: 276)
        view.backgroundColor = UIColor(hexString: "F6F6F7")
        view.add_CornerRadius(10)
        view.isHidden = true
        return view
    }()
    
    var commentLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    var buttonsArray: [PaymentsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsArray = MockItems.butttonArray()
        requestOperationDetail(documentId: documentId)
        setupUI()
    }

    @objc func back(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    func setupUI(){
        
        view.backgroundColor = .white
//        view.addSubview(closeButton)
//        closeButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10, width: 24, height: 24)
//        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        
        if  mainLabel.text == "Возврат!"{
            mainLabel.textColor = .red
        }
        if commentLabel.text == nil || commentLabel.text == "F6F6F7" {
            commentView.isHidden = true
        }
        
        switch categoryGroupLabel.text {
        case "Между своими":
            mainLabel.text = "Между своими"
            mainLabel.isHidden = false
            companyImage.isHidden = true
            recipient.isHidden = true
        case "Перевод Contact":
            categoryGroupLabel.isHidden = true
            mainLabel.text = categoryGroupLabel.text
            mainLabel.isHidden = false
        case "Перевод МИГ":
            categoryGroupLabel.isHidden = true
            mainLabel.text = categoryGroupLabel.text
            mainLabel.isHidden = false
        
        default:
            print("default")
        }
        
        transferImage.setDimensions(height: 64, width: 64)
        
        
        companyImage.setDimensions(height: 32, width: 32)
        
        commentView.addSubview(commentLabel)

        commentLabel.center(inView: commentView)
        
        
        
        stackView = UIStackView(arrangedSubviews: [transferImage, mainLabel, categoryGroupLabel, companyImage, nameOperationLabel, recipient, amount, commissionLabel, commentView, dateLabel])
//        stackView.backgroundColor = .systemYellow
    
        
        view.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 10, paddingBottom: 20, paddingRight: 10)
        
//        contactButtonStackView.anchor(left: view.leftAnchor, right: view.rightAnchor)

//        contactButtonStackView = UIStackView(arrangedSubviews: [changeButton, returnButton])

        
        contactButtonStackView.axis = .horizontal
        contactButtonStackView.alignment = .center
        contactButtonStackView.distribution = .fill
        contactButtonStackView.spacing = 10
        contactButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        contactButtonStackView.backgroundColor = .blue

//        stackView.addArrangedSubview(buttonStackView)
        

        
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        buttonStackView = UIStackView(arrangedSubviews: [changeButton, returnButton])
        buttonStackView.backgroundColor = .yellow
        
        
        //Add buttons
        changeButton.setDimensions(height: 40, width: 160)
        changeButton.setTitleColor(.black, for: UIControl.State.normal)
        changeButton.layer.cornerRadius = 10
        changeButton.setTitle("Изменить", for: .normal)
        changeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        changeButton.tintColor = .black
        changeButton.backgroundColor = UIColor(hexString: "F6F6F7")
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.sizeToFit()
        
        
        returnButton.setDimensions(height: 40, width: 160)
        returnButton.setTitleColor(.black, for: UIControl.State.normal)
        returnButton.layer.cornerRadius = 10
        returnButton.setTitle("Вернуть", for: .normal)
        returnButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        returnButton.tintColor = .black
        returnButton.backgroundColor = UIColor(hexString: "F6F6F7")
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        returnButton.sizeToFit()
        
    }
    
    @objc func toPrintForm(){
        let vc = PDFViewerViewController()
        vc.id = operation?.paymentOperationDetailID
        vc.printFormType = operation?.printFormType
        present(vc, animated: true, completion: nil)
    }
    
    @objc func openDetailVC(){
        let vc = ContactConfurmViewController()
        vc.confurmVCModel = confurmVCModel
        vc.doneButton.isHidden = true
        vc.smsCodeField.isHidden = true
        vc.addCloseButton()
        if operation?.printFormType == "sbp"{
            vc.confurmVCModel?.payToCompany = true
        }
        vc.title = "Детали операции"
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
    }
    
    func requestOperationDetail(documentId: String){
        
        let body = [ "documentId" : documentId
                     ] as [String : AnyObject]
        
        NetworkManager<GetOperationDetailDecodebleModel>.addRequest(.getOperationDetail, [:], body) { [self] model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    dateLabel.text = model.data?.dateForDetail
                    nameOperationLabel.text = "\(model.data?.payeeFullName ?? "") \n \(model.data?.payeePhone ?? model.data?.payeeCardNumber ?? "")"
                    if model.data?.payeeFullName == nil{
                        nameOperationLabel.isHidden = true
                    }
                    commissionLabel.text = "Комиссия: \n \(model.data?.payerFee  ?? 0.0)"
                    if model.data?.payerFee == 0{
                        commissionLabel.isHidden = true
                    }
                    if commissionLabel.text == "Комиссия: \n 0.0"{
                        commissionLabel.isHidden = true
                    }
                    operation = model.data
//                    let dict = Dict.shared.organization
                    let banks = Dict.shared.banks
//                    let banksInfo = Dict.shared.bankFullInfoList
                    for i in banks!{
                        if  model.data?.payeeBankName == i.memberNameRus{
                            self.companyImage.image = i.svgImage?.convertSVGStringToImage()
                        }
                    }
                    if self.companyImage.image == nil{
                        companyImage.isHidden = true
                    }
                    if operation?.printFormType == nil || operation?.paymentOperationDetailID == nil{
                        buttonsArray.remove(at: 1)
                        buttonsArray.remove(at: 0)
                    }
                    addButtons()
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
            }
        }
    }
    
    func addButtons(){
        let buttonsStack = UIStackView()
          buttonsStack.axis = .horizontal
          buttonsStack.spacing = 30
    buttonsStack.distribution = .fillEqually
    
    
    // create and add 3 50-pt height buttons to the stack view
        buttonsArray.forEach { str in
             
             let stackView = UIStackView()
             stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = 7
//             stackView.setDimensions(height: 92, width: 112)
             let a = UIButton()
//                a.layer.masksToBounds = true
             a.setDimensions(height: 56, width: 56)
                a.layer.cornerRadius = 28
             a.setTitleColor(.black, for: .normal)
             a.backgroundColor = UIColor(hexString: "F6F6F7")
                a.setImage(UIImage(systemName: str.iconName ?? ""), for: .normal)
        a.tintColor = .black
        if str.iconName == "star24size"{
            a.setImage(UIImage(named: "star24size"), for: .normal)
        }
             
             let b = UIButton()
                b.setTitle(str.name, for: [])
             b.setTitleColor(.black, for: .normal)
             b.setTitleColor(.gray, for: .highlighted)
             b.backgroundColor = .clear
            b.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            
             stackView.addArrangedSubview(a)
             stackView.addArrangedSubview(b)
             
             buttonsStack.addArrangedSubview(stackView)
             b.heightAnchor.constraint(equalToConstant: 24).isActive = true

        if str.name == "Детали"{
            a.addTarget(self, action: #selector(openDetailVC), for: .touchUpInside)
            b.addTarget(self, action: #selector(openDetailVC), for: .touchUpInside)
        } else if str.name == "+ Шаблон" {
            a.isUserInteractionEnabled = false
            b.isUserInteractionEnabled = false
            a.alpha = 0.3
            b.alpha = 0.3
        } else {
               a.addTarget(self, action: #selector(toPrintForm), for: .touchUpInside)
               b.addTarget(self, action: #selector(toPrintForm), for: .touchUpInside)
        }
            

         }
        stackView.addArrangedSubview(buttonsStack)

    }
    
    
}

extension OperationDetailViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
