//
//  CalculatorDepositCollectionViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit
import AnyFormatKit

protocol CalculatorDepositDelegate: AnyObject {
    func openDetailController(with model: [TermRateSumTermRateList]?)
}

class CalculatorDepositCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var summTextField: UITextField!
    @IBOutlet weak var minSummLabel: UILabel!
    @IBOutlet weak var dateDepositButton: UIButton!
    @IBOutlet weak var percentDepositLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var mainSummLabel: UILabel!
    @IBOutlet weak var summSlider: UISlider!
    
    let defaultValue: Float = 500000
    let defaultDate: Int = 366
    weak var delegate: CalculatorDepositDelegate?
    var viewModel: OpenDepositDatum? {
        didSet {
            configure()
        }
    }
    
    var choosenRateList: [TermRateSumTermRateList]? 
    
    var choosenRate: TermRateSumTermRateList? {
        didSet {
            guard let choosenRate = choosenRate else { return }
            dateDepositButton.setTitle(choosenRate.termName ?? "", for: .normal)
            percentDepositLabel.text = "\(choosenRate.rate ?? 0.0)%"
            guard let text = self.summTextField.text else { return }
            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            guard let value = Float(unformatText) else { return }
            calculateSumm(with: value)
        }
    }
    
    var currencyCode = "RUB"
    // MARK: - Formatters
    let moneyInputController = TextFieldStartInputController()
    var moneyFormatter: SumTextInputFormatter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## \(self.currencyCode.getSymbol() ?? "₽")")
        moneyInputController.formatter = moneyFormatter
        summTextField.delegate = moneyInputController
        dateDepositButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        dateDepositButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: summTextField, queue: .main) { _ in
            guard let text = self.summTextField.text else { return }
            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            guard let value = Float(unformatText) else { return }
            self.summSlider.setValue(value, animated: true)
            self.calculateSumm(with: value)
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: summTextField, queue: .main) { _ in
            guard let text = self.summTextField.text else { return }
            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            guard let value = Int(unformatText) else { return }
            if value < self.viewModel?.generalСondition?.minSum ?? 5000 {
                let newText = self.moneyFormatter?.format("\(self.viewModel?.generalСondition?.minSum ?? 5000)")
                self.summTextField.text = newText
                self.calculateSumm(with: Float(self.viewModel?.generalСondition?.minSum ?? 5000))
            }
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value: Float = Float(Int(sender.value/1000)*1000)
        let newText = self.moneyFormatter?.format("\(value)")
        summTextField.text = newText
        calculateSumm(with: value)
    }
    
    
    @IBAction func dateButtonTapped(_ sender: Any) {
        print(#function)
        delegate?.openDetailController(with: choosenRateList)
    }
    
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        minSummLabel.text = "От \((viewModel.generalСondition?.minSum ?? 0)/1000) тыс. ₽"

        /// design
        let topTextColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[1] ?? "")
        backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?[1] ?? "")
        
        titleLabel.textColor = topTextColor
        summTextField.textColor = topTextColor
        percentDepositLabel.textColor = topTextColor
        dateDepositButton.tintColor = topTextColor
                
        bottomView.backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?[2] ?? "")
        let bottomTextColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[2] ?? "")
        mainSummLabel.textColor = bottomTextColor
        incomeLabel.textColor = bottomTextColor
        
        setupCasculator()
        
    }

    private func setupCasculator() {
        chooseRate(from: defaultValue)
        choosenRateList?.forEach({ rateSumTermRateList in
            if rateSumTermRateList.term == defaultDate {
                choosenRate = rateSumTermRateList
            }
        })
        calculateSumm(with: defaultValue)
    }
    
    
    ///Формула для расчета дохода по вкладу: (initialAmount * interestRate * termDay/AllDay) / 100
///    initialAmount - первоначальная сумма вложений
///    interestRate – годовая ставка
///    termDay – кол-во дней вклада
///    AllDay - кол-во дней в году
    private func calculateSumm(with value: Float) {
        chooseRate(from: value)
        let interestRate = Float(choosenRate?.rate ?? 0)
        let termDay = Float(choosenRate?.term ?? 0)
        
        let income = ( (value * interestRate * termDay) / 365 ) / 100

        incomeLabel.text = moneyFormatter?.format("\(income)")
        mainSummLabel.text = moneyFormatter?.format("\(value + income)")
    }
    
    private func chooseRate(from value: Float) {
        guard let mainRateList = self.viewModel?.termRateList else { return }
        mainRateList.forEach { termRateList in
            if termRateList.сurrencyCode == "810" {
                let termRateSumm = termRateList.termRateSum
                termRateSumm?.forEach({ rateSum in
                    if value >= Float(rateSum.sum ?? 0) {
                        choosenRateList = rateSum.termRateList
                    }
                })
            }
        }
    }
    
}
