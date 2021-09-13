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
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var operatorImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
//    @IBOutlet weak var buttonView: UIStackView!
    
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
    
    @IBAction func detailBattonTapped(_ sender: Any) {
        print(#function)
        detailTapped?()
    }
    
    
    func setupData(with model: ConfirmViewControllerModel) {
//        buttonView.isHidden = !model.statusIsSuccses
        statusImageView.image = model.statusIsSuccses ? #imageLiteral(resourceName: "OkOperators") : #imageLiteral(resourceName: "errorIcon")
        operatorImageView.image = UIImage()
        
        if (UserDefaults.standard.object(forKey: "OPERATOR_IMAGE") != nil) {
            let im = UserDefaults.standard.object(forKey: "OPERATOR_IMAGE") as? String ?? ""
            if im != "" {
                let dataDecoded : Data = Data(base64Encoded: im, options: .ignoreUnknownCharacters)!
                
                let decodedimage = UIImage(data: dataDecoded)
                operatorImageView.image = decodedimage
                
            } else {
                operatorImageView.image = UIImage(named: "GKH")
            }
            
        }
        statusLabel.text = model.statusIsSuccses
            ? "Успешный перевод" : "Операция неуспешна!"
        summLabel.text = model.summTransction
        
    }
    
}
