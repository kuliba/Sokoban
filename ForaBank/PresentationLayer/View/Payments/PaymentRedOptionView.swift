
import Foundation

class PaymentRedOptionView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var optionNameLabel: UILabel!
    @IBOutlet weak var optionValueLabel: UILabel!
    @IBOutlet weak var optionNumberLabel: UILabel!
    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var providerImageView: UIImageView!

    @IBOutlet weak var leadingToArrowConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingToSuperviewConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitRed()
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInitRed()
    
    }

    private func commonInitRed() {
        Bundle.main.loadNibNamed(String(describing: RedPagerView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        arrowsImageView.isHidden = true
      
        
    }

    internal func setupLayout(withPickerItem pickerItem: IPickerItem, isDroppable: Bool) {
        leadingToArrowConstraint.isActive = isDroppable
        leadingToSuperviewConstraint.isActive = !isDroppable

        optionNameLabel.text = pickerItem.title
        optionNumberLabel.text = pickerItem.subTitle
        optionValueLabel.text = String(pickerItem.value)

        updateConstraints()
    }
}
