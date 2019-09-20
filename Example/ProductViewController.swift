//
//  ProductViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 17/04/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
import RezolveSDK

class ProductViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var quantityPicker: UIPickerView!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var finalPriceLabel: UILabel!
    private lazy var session = (UIApplication.shared.delegate as! AppDelegate).session!
    private var orderId: String? = nil
    private var checkoutBundle: CheckoutBundle? = nil
    var product: Product!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = product.title
        if let description = product.description, let attributedString = try? NSAttributedString(data: Data(description.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            descriptionLabel.attributedText = attributedString
        }
        priceLabel.text = "$\(product.price)"
        imageView.imageFromUrl(urlString: product.images[0])
        quantityPicker.dataSource = self
        quantityPicker.delegate = self
        checkout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orderId = self.orderId, segue.identifier == "showOrderDetails" {
            let orderDetailsViewController = segue.destination as! OrderDetailsViewController
            orderDetailsViewController.orderId = orderId
            orderDetailsViewController.product = product
        }
    }
    
    private func checkout() {
        finalPriceLabel.text = "Loading..."
        buyButton.isEnabled = false
        let checkoutProduct = CheckoutProduct(id: product.id, quantity: Decimal(quantityPicker.selectedRow(inComponent: 0) + 1))
        session.paymentOptionManager.getPaymentOptionFor(checkoutProduct: checkoutProduct, merchantId: product.merchantId) { result in
            switch result {
            case .success(let option):
                self.createPhone(checkoutProduct, option!)
                print("\(option!)")
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    @IBAction private func buyClick(_ sender: Any) {
        self.session.checkoutManager.buy(bundle: checkoutBundle!) { result in
            switch result {
            case .success(let order):
                self.orderId = order!.id
                self.performSegue(withIdentifier: "showOrderDetails", sender: self)
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    private func createPhone(_ product: CheckoutProduct, _ option: PaymentOption) {
        session.phonebookManager.getAll { result in
            switch result {
            case .success(let phone):
                self.createAddress(phone![0], product, option)
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    private func createAddress(_ phone: Phone, _ product: CheckoutProduct, _ option: PaymentOption) {
        let address = Address(id: "", fullName: "John Smith", shortName: "JS", line1: "Lambeth", line2: "", city: "London", state: "", zip: "SE1 7PB", country: "GB", phoneId: phone.id)
        session.addressbookManager.create(address: address) { result in
            switch result {
            case .success(let address):
                self.createCard(phone, address!, product, option)
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    private func createCard(_ phone: Phone, _ address: Address, _ product: CheckoutProduct, _ option: PaymentOption) {
        let paymentCard = PaymentCard(id: "", type: "debit", cardHolderName: "John Curtis", expiresOn: "0817", validFrom: "0817", brand: "visa", addressId: address.id, shortName: "black amex", pan4: "1234", pan6: "123456", pan: "123456")
        self.session.walletManager.create(paymentCard: paymentCard) { result in
            switch result {
            case .success(let card):
                self.checkout(phone, address, product, option, PaymentRequest(paymentCard: card!, cvv: "123"))
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    private func checkout(_ phone: Phone, _ address: Address, _ product: CheckoutProduct, _ option: PaymentOption, _ paymentRequest: PaymentRequest) {
        let shippingMethod = CheckoutShippingMethod(type: "flatrate", addressId: address.id)
        let location = Location(longitude: 80.0, latitude: 80.0)
        let checkoutBundle = CheckoutBundle(
                checkoutProduct: product, shippingMethod: shippingMethod, merchantId: self.product.merchantId,
                optionId: option.id, paymentMethod: option.supportedPaymentMethods![0],
                paymentRequest: paymentRequest, phoneId: phone.id, location: location)

        self.session.checkoutManager.checkout(bundle: checkoutBundle) { result in
            switch result {
            case .success(let checkoutResult):
                var princeInfo = ""
                checkoutResult!.breakdown.forEach({ (price) in
                    princeInfo += "\(price.type): \(price.amount)\n"
                })
                self.finalPriceLabel.text = "\(princeInfo)total: $\(checkoutResult!.finalPrice)"
                self.buyButton.isEnabled = true
                self.checkoutBundle = checkoutBundle
            case .failure(let error):
                print("\(error)")
            }
        }
    }


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 20
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        checkout()
    }
}
