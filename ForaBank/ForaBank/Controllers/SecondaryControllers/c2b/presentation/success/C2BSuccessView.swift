import UIKit

class C2BSuccessView: UIView {
    static var svgImg = ""
    static var statusImg: UIImage? = nil
    static var statusText = ""
    static var sourceModel = ""
    static var bankImg: UIImage? = nil
    static var bankName = ""

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
    
    
    @IBOutlet weak var layoutLink: UIStackView!
    
    @IBOutlet weak var labelLink: UILabel!

    @IBOutlet weak var recipientIcon: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed("C2BSuccess", owner: self, options: nil)
        contentView.fixInView(self)
        layer.shadowRadius = 16
        labelNameRecipient.text = C2BDetailsViewModel.recipientText
        labelDescrRecipient.text = C2BDetailsViewModel.recipientDescription
        recipientIcon.image = C2BDetailsViewModel.recipientIcon
        
        if let linkStr = C2BDetailsViewModel.operationDetail?.shopLink {
            if linkStr.description.isEmpty {
                layoutLink.isHidden = true
            } else {
                layoutLink.isHidden = false
                labelLink.text = C2BDetailsViewModel.operationDetail?.shopLink
            }
        } else {
            layoutLink.isHidden = true
        }

        var statusOp = ""
        var docStatus = C2BDetailsViewModel.makeTransfer?.data?.documentStatus
        switch (docStatus) {
        case "IN_PROGRESS":
            C2BSuccessView.statusImg = #imageLiteral(resourceName: "waiting")
            docStatus = "Запрос принят в обработку"
            C2BSuccessView.statusText = "В обработке"
            break
        case "COMPLETED":
            C2BSuccessView.statusImg = #imageLiteral(resourceName: "OkOperators")
            statusOp = "Успешный перевод"
            C2BSuccessView.statusText = "Успешно"
            break
        case "COMPLETE":
            C2BSuccessView.statusImg = #imageLiteral(resourceName: "OkOperators")
            statusOp = "Успешный перевод"
            C2BSuccessView.statusText = "Успешно"
            break
        case .none:
            C2BSuccessView.statusImg = #imageLiteral(resourceName: "rejected")
            statusOp = "Операция неуспешна!"
            C2BSuccessView.statusText = "Отказ"
            break
        case .some(_):
            C2BSuccessView.statusImg = #imageLiteral(resourceName: "rejected")
            statusOp = "Операция неуспешна!"
            C2BSuccessView.statusText = "Отказ"
            break
        }

        statusImageView.image = C2BSuccessView.statusImg
        statusLabel.text = statusOp
        let sumDouble = Double(C2BDetailsViewModel.sum)
        summLabel.text = sumDouble?.currencyFormatter() ?? "0.0"
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        print(#function)
        saveTapped?()
    }

    @IBAction func detailBattonTapped(_ sender: Any) {
        print(#function)
        detailTapped?()
    }
}
