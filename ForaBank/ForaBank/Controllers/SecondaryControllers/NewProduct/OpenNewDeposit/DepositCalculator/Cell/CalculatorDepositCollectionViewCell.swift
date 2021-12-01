//
//  CalculatorDepositCollectionViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit
import AnyFormatKit

class CalculatorDepositCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var summTextField: UITextField!
    @IBOutlet weak var minSummLabel: UILabel!
    @IBOutlet weak var dateDepositLabel: UILabel!
    @IBOutlet weak var percentDepositLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var mainSummLabel: UILabel!
    @IBOutlet weak var summSlider: UISlider!
    

    var viewModel: OpenDepositDatum? {
        didSet {
            configure()
        }
    }
    var currencyCode = "RUB"
    let moneyInputController = TextFieldStartInputController()
    // MARK: - Formatters
    var moneyFormatter: SumTextInputFormatter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## \(self.currencyCode.getSymbol() ?? "₽")")
        moneyInputController.formatter = moneyFormatter
        summTextField.delegate = moneyInputController
//        summTextField.delegate = self
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: summTextField, queue: .main) { _ in
            guard let text = self.summTextField.text else { return }
            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            guard let value = Float(unformatText) else { return }
            self.summSlider.setValue(value, animated: true)
            self.calculateSumm(with: value)
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value: Float = Float(Int(sender.value/1000)*1000)
        let newText = self.moneyFormatter?.format("\(value)")
        summTextField.text = newText
        calculateSumm(with: value)
    }
    
    @IBAction func dateButtonDidTapped(_ sender: Any) {
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }


        minSummLabel.text = "От \((viewModel.generalСondition?.minSum ?? 0)/1000) тыс. ₽"

        
        /// design
        backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?[1] ?? "")
        bottomView.backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?[2] ?? "")
        titleLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[1] ?? "")
        summTextField.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[1] ?? "")
        percentDepositLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[1] ?? "")
        dateDepositLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[1] ?? "")
        mainSummLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[1] ?? "")
        incomeLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?[1] ?? "")
    }
    
    ///Формула для расчета дохода по вкладу: (initialAmount * interestRate * termDay/AllDay) / 100
///    initialAmount - первоначальная сумма вложений
///    interestRate – годовая ставка
///    termDay – кол-во дней вклада
///    AllDay - кол-во дней в году
    private func calculateSumm(with value: Float) {
        print(value)
        
        let income = ( (value * 6.95 * 365) / 365 ) / 100

        incomeLabel.text = moneyFormatter?.format("\(income)")
        mainSummLabel.text = moneyFormatter?.format("\(value + income)")
    }
    
}
