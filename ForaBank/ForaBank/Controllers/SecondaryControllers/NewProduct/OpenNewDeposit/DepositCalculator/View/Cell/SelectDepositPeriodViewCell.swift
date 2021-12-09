//
//  SelectDepositPeriodViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit

class SelectDepositPeriodViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var viewModel: TermRateSumTermRateList? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.termName
        subTitleLabel.text = "\(viewModel.term ?? 0) \(WordDeclensionUtil.getWordInDeclension(type: WordDeclensionEnum().day, n: viewModel.term ))"
    }
//
//    private func getWordInDeclension(n: Int?) -> String {
//        guard let n = n else { return "" }
//        // смотрим две последние цифры
//        var result: Int = n % 100
//
//        if (result >= 10 && result <= 20) {
//            // если окончание 11 - 20
//            return "дней"
//        }
//
//        // смотрим одну последнюю цифру
//        result = n % 10;
//        if (result == 0 || result > 4) {
//            return "дней"
//        }
//        if (result > 1) {
//            return "дня"
//        }
//        if (result == 1) {
//            return "день"
//        }
//        return ""
//    }
    
}
