import UIKit

class InternetTVSuccessView: UIView {
    static var svgImg = ""
    let kContentXibName = "InternetTVSuccess"
    var saveTapped: (() -> Void)?
    var detailTapped: (() -> Void)?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var operatorImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

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
}
