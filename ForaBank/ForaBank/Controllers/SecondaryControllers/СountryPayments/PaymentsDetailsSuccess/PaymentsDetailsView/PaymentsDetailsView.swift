//
//  ConfurmPaymentsView.swift
//  ForaBank
//
//  Created by Mikhail on 19.06.2021.
//

import UIKit

class PaymentsDetailsView: UIView {

    //MARK: - Property
    let kContentXibName = "PaymentsDetailsView"
    
    /// Замыкание для действия по нажатию кнопки "Сохранить чек"
    var saveTapped: (() -> Void)?
    /// Замыкание для действия по нажатию кнопки "Детали операции"
    var detailTapped: (() -> Void)?
    
    var changeTapped: (() -> Void)?
    
    var returnTapped: (() -> Void)?
    
    var templateTapped: (() -> Void)?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var operatorImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var changeButtonsStackView: UIStackView!
    @IBOutlet weak var detailButtonsStackView: UIStackView!
    
    @IBOutlet weak var templateButtonContainerView: UIStackView!
    @IBOutlet weak var templateButton: UIButton!
    @IBOutlet weak var templateButtonTitle: UILabel!
    @IBOutlet weak var templateButtonCheckMarkIcon: UIImageView!
  
    @IBOutlet weak var documentStackView: UIStackView!
    
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            
            setupData(with: model)
        }
    }
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        changeButtonsStackView.isHidden = true
        infoLabel.isHidden = true
        layer.shadowRadius = 16
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveTapped?()
    }
    
    @IBAction func changeButtonDidTapped(_ sender: Any) {
        changeTapped?()
    }
    
    @IBAction func returnButtonDidTappeed(_ sender: Any) {
        returnTapped?()
    }
    
    @IBAction func detailBattonTapped(_ sender: Any) {
        detailTapped?()
    }
    
    @IBAction func templateButtonDidTapped(_ sender: UIButton) {
        templateTapped?()
    }
    
    func setupData(with model: ConfirmViewControllerModel) {

        operatorImageView.image = UIImage()
        if model.type == .contact {
            changeButtonsStackView.isHidden = false
        } else {
            changeButtonsStackView.isHidden = true
        }
        
        if model.operatorImage != "" {
            operatorImageView.image = model.operatorImage.convertSVGStringToImage()
        }
        
        if (UserDefaults.standard.object(forKey: "OPERATOR_IMAGE") != nil) {
            let im = UserDefaults.standard.object(forKey: "OPERATOR_IMAGE") as? String ?? ""
            if im != "" {
                let dataDecoded : Data = Data(base64Encoded: im, options: .ignoreUnknownCharacters)!
                let decodedimage = UIImage(data: dataDecoded)
                operatorImageView.image = decodedimage
                UserDefaults.standard.removeObject(forKey: "OPERATOR_IMAGE")
            } else {
//                operatorImageView.isHidden  = true
            }
            
        }
        let system = model.paymentSystem
        let navImage: UIImage = system?.svgImage?.convertSVGStringToImage() ?? UIImage()
        summLabel.text = model.summTransction
        
        switch model.status {
        case .inProgress:
            statusLabel.text = "В обработке"
            statusImageView.image = UIImage(named: "waiting")
            
        case .succses:
            statusLabel.text = "Успешный перевод"
            statusImageView.image = UIImage(named: "OkOperators")
            if let paymentSystem = self.confurmVCModel?.paymentSystem {
                let paymentImage: UIImage = paymentSystem.svgImage?.convertSVGStringToImage() ?? UIImage()
                operatorImageView.image = paymentImage
            }
        
        case .antifraudCanceled:
            statusLabel.text = "Операция временно приостановлена в целях безопасности"
            infoLabel.text = Payments.Success.antifraudSubtitle
            statusImageView.image = UIImage(named: "waiting")
            summLabel.text = model.summTransction
            
        case .error:
            statusLabel.text = "Операция неуспешна!"
            statusImageView.image = UIImage(named: "waiting")
            detailButtonsStackView.isHidden = true
            
        case .returnRequest:
            statusLabel.text = "Запрос на возврат перевода принят в обработку"
            statusImageView.image = UIImage(named: "waiting")
            changeButtonsStackView.isHidden = true
            detailButtonsStackView.isHidden = false
            templateButtonContainerView.isHidden = true
            operatorImageView.image = navImage
            
        case .changeRequest:
            statusLabel.text = "Запрос на изменение перевода принят в обработку"
            statusImageView.image = UIImage(named: "waiting")
            changeButtonsStackView.isHidden = true
            detailButtonsStackView.isHidden = false
            templateButtonContainerView.isHidden = true
            operatorImageView.image = navImage
            
        case .processing:
            statusLabel.text = "Операция ожидает подтверждения"
            statusImageView.image = UIImage(named: "waiting")
            detailButtonsStackView.isHidden = true
            
        case .timeOut:
            statusLabel.text = "Запрос принят в обработку"
            statusImageView.image = UIImage(named: "timeOutImage")
            infoLabel.text = " "
            summLabel.text = " "
            operatorImageView.image = UIImage()
            documentStackView.isHidden = true
            templateButtonContainerView.isHidden = true
        }
        
        
        if model.operatorImage != "" {
            operatorImageView.image = model.operatorImage.convertSVGStringToImage()
        }
        
        if (UserDefaults.standard.object(forKey: "OPERATOR_IMAGE") != nil) {
            let im = UserDefaults.standard.object(forKey: "OPERATOR_IMAGE") as? String ?? ""
            if im != "" {
                let dataDecoded : Data = Data(base64Encoded: im, options: .ignoreUnknownCharacters)!
                let decodedimage = UIImage(data: dataDecoded)
                operatorImageView.image = decodedimage
                UserDefaults.standard.removeObject(forKey: "OPERATOR_IMAGE")
            } else {
//                operatorImageView.isHidden  = true
            }
            
        }
        
        summLabel.text = model.summTransction
        
        // template button
        if let templateButtonViewModel = model.templateButtonViewModel {
            
            updateTemplateButton(with: templateButtonViewModel)
            
        } else {
            
            templateButtonContainerView.isHidden = true
        }
    }
    
    func updateTemplateButton(with viewModel: ConfirmViewControllerModel.TemplateButtonViewModel) {
        templateButton.layer.cornerRadius = 28
        templateButton.clipsToBounds = true
        switch viewModel {
        case .template:
            templateButton.setImage(UIImage(named: "Template_Star"), for: .normal)
            templateButton.setBackgroundColor(UIColor(red: 0.133, green: 0.757, blue: 0.514, alpha: 1), for: .normal)
            templateButtonTitle.text = "Шаблон"
            templateButtonTitle.textColor = UIColor(red: 0.133, green: 0.757, blue: 0.514, alpha: 1)
            templateButton.isUserInteractionEnabled = false
            templateButtonCheckMarkIcon.isHidden = false
            
        case .sfp:
            templateButton.setImage(UIImage(named: "star24size"), for: .normal)
            templateButton.setBackgroundColor(UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1), for: .normal)
            templateButtonTitle.text = "+ Шаблон"
            templateButtonTitle.textColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1)
            templateButton.isUserInteractionEnabled = true
            templateButtonCheckMarkIcon.isHidden = true
        }
    }
}
