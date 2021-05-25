
import Foundation

protocol PaymentDetailsPresenterDelegate: class {
    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool)
    func didFinishPreparation(success: Bool, data: DataClassPayment?)
    func didPrepareData(data: DataClassPayment?)

//    func preparePaymentData(prepareData: DataClassPayment)
}

protocol IPaymentDetailsPresenter: class {
    var delegate: PaymentDetailsPresenterDelegate? { get }
}
