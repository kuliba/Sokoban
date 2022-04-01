import UIKit

class C2BSuccessView: UIView {
    static var svgImg = ""
    let kContentXibName = "C2BSuccess"
    var saveTapped: (() -> Void)?
    var detailTapped: (() -> Void)?

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var operatorImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var summLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var imgRecipient: UIImageView!
    @IBOutlet weak var labelNameRecipient: UILabel!
    @IBOutlet weak var labelDescrRecipient: UILabel!
    
    
    var confirmModel: C2BDetailsFormViewModel? {
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
        labelNameRecipient.text = C2BDetailsViewModel.recipientText
        labelDescrRecipient.text = C2BDetailsViewModel.recipientDescription
        C2BDetailsViewModel.makeTransfer
        let docStatus = C2BDetailsViewModel.makeTransfer?.data?.documentStatus
        C2BDetailsViewModel.modelCreateC2BTransfer

        switch (docStatus) {
        case "IN_PROGRESS":
            statusImageView.image = #imageLiteral(resourceName: "waiting")
            statusLabel.text = "Запрос принят в обработку"
            break
        case "COMPLETED":
            statusImageView.image = #imageLiteral(resourceName: "OkOperators")
            statusLabel.text = "Успешный перевод"
            break
        case .none:
            statusImageView.image = #imageLiteral(resourceName: "errorIcon")
            statusLabel.text = "Операция неуспешна!"
            break
        case .some(_):
            statusImageView.image = #imageLiteral(resourceName: "errorIcon")
            statusLabel.text = "Операция неуспешна!"
            break
        }
        summLabel.text = C2BDetailsViewModel.sum
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        print(#function)
        saveTapped?()
    }

    @IBAction func detailBattonTapped(_ sender: Any) {
        print(#function)
        detailTapped?()
    }

    func setupData(with model: C2BDetailsFormViewModel) {
        statusImageView.image = model.statusIsSuccess ? #imageLiteral(resourceName: "OkOperators") : #imageLiteral(resourceName: "errorIcon")
        if !C2BSuccessView.svgImg.isEmpty {
            operatorImageView.image = C2BSuccessView.svgImg.convertSVGStringToImage()
            C2BSuccessView.svgImg = ""
        }
        statusLabel.text = model.statusIsSuccess
                ? "Успешный перевод" : "Операция неуспешна!"
        summLabel.text = model.sumTransaction

    }
}
