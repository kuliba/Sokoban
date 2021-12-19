//
//  OpenNewDepositViewControllerCell.swift
//  ForaBank
//
//  Created by Mikhail on 30.11.2021.
//

import UIKit
import SDWebImage

protocol OpenNewDepositDelegate: AnyObject {
    func openDetailController(indexPath: IndexPath)
    func openCalculatorController(indexPath: IndexPath)
}

class OpenNewDepositViewControllerCell: UICollectionViewCell {

    var viewModel: OpenDepositDatum? {
        didSet {
            configure()
        }
    }
    var index: IndexPath!
    weak var delegate: OpenNewDepositDelegate?
    
    @IBOutlet weak var depositNameLabel: UILabel!
    @IBOutlet weak var procentLabel: UILabel!
    @IBOutlet weak var depositSummFrom: UILabel!
    @IBOutlet weak var depositDateFrom: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var depositImage: UIImageView!
    @IBOutlet weak var moreDetailButton: UIButton! {
        didSet {
            moreDetailButton?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - IBAction
    @IBAction func moreDetailButtonTapped(_ sender: Any) {
        print(#function)
        delegate?.openDetailController(indexPath: index)
    }
    
    @IBAction func openDepositButtonTapped(_ sender: Any) {
        print(#function)
        delegate?.openCalculatorController(indexPath: index)
    }
    
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        depositNameLabel.text = viewModel.name
        procentLabel.text = "до \(viewModel.generalСondition?.maxRate ?? 0) %"
        depositSummFrom.text = "От \(viewModel.generalСondition?.minSum ?? 0) ₽"
        depositDateFrom.text = "От \(viewModel.generalСondition?.minTerm ?? 0) дня"
        if let detailText = viewModel.generalСondition?.generalTxtСondition {
            var labelText = ""
            detailText.forEach { element in
                labelText = labelText + "• " + element + "\n"
            }
            detailLabel.text = labelText
        }
        /// design
        backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?.first ?? "")
        depositNameLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        depositSummFrom.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        depositDateFrom.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        detailLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        moreDetailButton.tintColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        
        let result = URLConstruct.setUrl(.https, .qa, "/\(viewModel.generalСondition?.imageLink ?? "")")
        switch result {
        case .success(let url):
            depositImage.sd_setImage(with: url, completed: nil)
        case .failure(let error):
            debugPrint(error)
            return
        }
        
        
    }
    
}
