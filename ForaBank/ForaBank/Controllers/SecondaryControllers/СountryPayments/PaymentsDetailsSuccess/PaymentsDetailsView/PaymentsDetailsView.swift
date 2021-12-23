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
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var operatorImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
//    @IBOutlet weak var buttonView: UIStackView!
    @IBOutlet weak var changeButtonsStackView: UIStackView!
    @IBOutlet weak var detailButtonsStackView: UIStackView!
    
    
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
        
        layer.shadowRadius = 16
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        print(#function)
        saveTapped?()
    }
    
    @IBAction func changeButtonDidTapped(_ sender: Any) {
        changeTapped?()
    }
    
    @IBAction func returnButtonDidTappeed(_ sender: Any) {
        returnTapped?()
    }
    
    @IBAction func detailBattonTapped(_ sender: Any) {
        print(#function)
        detailTapped?()
    }
    
    
    func setupData(with model: ConfirmViewControllerModel) {
//        buttonView.isHidden = !model.statusIsSuccses
        
        if model.type == .contact {
            changeButtonsStackView.isHidden = false
        } else {
            changeButtonsStackView.isHidden = true
        }
        
        
        switch model.status {
        case .succses:
            statusLabel.text = "Успешный перевод"
            statusImageView.image = UIImage(named: "OkOperators")
        case .error:
            statusLabel.text = "Операция неуспешна!"
            statusImageView.image = UIImage(named: "errorIcon")
//            statusImageView.image = #imageLiteral(resourceName: "errorIcon") waiting
        case .returnRequest:
            statusLabel.text = "Запрос на возврат перевода принят в обработку"
            statusImageView.image = UIImage(named: "waiting")
            changeButtonsStackView.isHidden = true
            detailButtonsStackView.isHidden = true
        case .changeRequest:
            statusLabel.text = "Запрос на изменения перевода принят в обработку"
            statusImageView.image = UIImage(named: "waiting")
            changeButtonsStackView.isHidden = true
            detailButtonsStackView.isHidden = true
        case .processing:
            statusLabel.text = "Операция ожидает подтверждения"
            statusImageView.image = UIImage(named: "waiting")
            detailButtonsStackView.isHidden = true
        }
        
        
        operatorImageView.image = UIImage()
        
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
        
        
    }
    
}
