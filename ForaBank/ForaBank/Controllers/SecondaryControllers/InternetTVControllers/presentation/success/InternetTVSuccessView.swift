import UIKit

class InternetTVSuccessView: UIView {
    static var svgImg = ""
    let kContentXibName = "InternetTVSuccess"
    var saveTapped: (() -> Void)?
    var detailTapped: (() -> Void)?
    var templateTapped: (() -> Void)?
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var operatorImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var templateButtonCheckMarkIcon: UIImageView!
    @IBOutlet weak var templateButton: UIButton!
    @IBOutlet weak var templateButtonTitle: UILabel!
    var confirmModel: InternetTVConfirmViewModel? {
        didSet {
            guard let model = confirmModel else { return }
            setupData(with: model)
        }
    }

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
    
    @IBAction func templateBattonTapped(_ sender: Any) {
        
        templateTapped?()
    }

    func setupData(with model: InternetTVConfirmViewModel) {
        statusImageView.image = model.statusIsSuccess ? #imageLiteral(resourceName: "OkOperators") : #imageLiteral(resourceName: "errorIcon")

        if !InternetTVSuccessView.svgImg.isEmpty {
            operatorImageView.image = InternetTVSuccessView.svgImg.convertSVGStringToImage()
            InternetTVSuccessView.svgImg = ""
        }

        statusLabel.text = model.statusIsSuccess
            ? "Успешный перевод" : "Операция неуспешна!"
        summLabel.text = model.sumTransaction
    }
    
    func updateTemplateButton(with viewModel: InternetTVConfirmViewModel.TemplateButtonViewModel) {
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

