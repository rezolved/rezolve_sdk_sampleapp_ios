//
//  ProductViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 17/04/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
import RezolveSDK

class ProductViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var quantityPicker: UIPickerView!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var finalPriceLabel: UILabel!
    
    // MARK: - Private properties
    
    private lazy var rezolveSession = (UIApplication.shared.delegate as! AppDelegate).rezolveSession!
    private var orderId: String? = nil
    private var checkoutBundle: CheckoutBundle? = nil
    
    // MARK: - Public properties
    
    var product: Product!
    
     // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sepupUI()
        configurePicker()
        checkout()
    }
    
    // MARK: - User Interactions
    
    @IBAction private func buyClick(_ sender: Any) {
        //        self.rezolveSession.checkoutManager.buy(bundle: checkoutBundle!) { result in
        //            switch result {
        //            case .success(let order):
        //                self.orderId = order!.id
        //                self.performSegue(withIdentifier: "showOrderDetails", sender: self)
        //            case .failure(let error):
        //                print("\(error)")
        //            }
        //        }
    }
    
    // MARK: - Helper methods
    
    private func sepupUI() {
        navigationItem.title = product.title
        priceLabel.text = "$\(product.price)"
        imageView.imageFromUrl(urlString: product.images[0])
        
        if let attributedString = try? NSAttributedString(data: Data(product.description.utf8),
                                                          options: [.documentType: NSAttributedString.DocumentType.html],
                                                          documentAttributes: nil) {
            descriptionLabel.attributedText = attributedString
        }
    }
    
    private func configurePicker() {
        quantityPicker.dataSource = self
        quantityPicker.delegate = self
    }
    
    // MARK: - Checkout methods
    
    private func checkout() {
        finalPriceLabel.text = "Loading..."
        buyButton.isEnabled = false
        
        let placement = ProductPlacement(adID: nil, placementID: nil)
        
        let checkoutProduct = CheckoutProduct(id: product.id,
                                              qty: Decimal(quantityPicker.selectedRow(inComponent: 0) + 1),
                                              productPlacement: placement,
                                              configurableOptions: [],
                                              customOptions: [])
        
        rezolveSession.paymentOptionManager.getProductOptions(checkoutProduct: checkoutProduct,
            merchantId: product.merchantId,
            callback: { newPaymentOption in
                print("Dupa")
                
            }, errorCallback: { error in
               print(error)
        })
        
//        rezolveSession.paymentOptionManager.getPaymentOptionFor(checkoutProduct: checkoutProduct, merchantId: product.merchantId) { result in
//            switch result {
//            case .success(let option):
//                self.createPhone(checkoutProduct, option!)
//                print("\(option!)")
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
    }

    private func createPhone(_ product: CheckoutProduct, _ option: PaymentOption) {
//        rezolveSession.phonebookManager.getAll { result in
//            switch result {
//            case .success(let phone):
//                self.createAddress(phone![0], product, option)
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
    }

    private func createAddress(_ phone: Phone, _ product: CheckoutProduct, _ option: PaymentOption) {
//        let address = Address(id: "", shortName: "John Smith", line1: "Lambeth", line2: "", city: "London", state: "", zip: "SE1 7PB", country: "GB")
//        rezolveSession.addressbookManager.create(address: address) { result in
//            switch result {
//            case .success(let address):
//                self.createCard(phone, address!, product, option)
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
    }

    private func createCard(_ phone: Phone, _ address: Address, _ product: CheckoutProduct, _ option: PaymentOption) {
//        let paymentCard = PaymentCard(id: "", type: "debit", cardHolderName: "John Curtis", expiresOn: "0817", validFrom: "0817", brand: "visa", addressId: address.id, shortName: "black amex", pan4: "1234", pan6: "123456", pan: "123456")
//        self.rezolveSession.walletManager.create(paymentCard: paymentCard) { result in
//            switch result {
//            case .success(let card):
//                self.checkout(phone, address, product, option, PaymentRequest(paymentCard: card!, cvv: "123"))
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
    }

    private func checkout(_ phone: Phone, _ address: Address, _ product: CheckoutProduct, _ option: PaymentOption, _ paymentRequest: PaymentRequest) {
//        let shippingMethod = CheckoutShippingMethod(type: "flatrate", addressId: address.id)
//        let location = Location(longitude: 80.0, latitude: 80.0)
//        let checkoutBundle = CheckoutBundle(
//                checkoutProduct: product, shippingMethod: shippingMethod, merchantId: self.product.merchantId,
//                optionId: option.id, paymentMethod: option.supportedPaymentMethods![0],
//                paymentRequest: paymentRequest, phoneId: phone.id, location: location)
//
//        self.rezolveSession.checkoutManager.checkout(bundle: checkoutBundle) { result in
//            switch result {
//            case .success(let checkoutResult):
//                var princeInfo = ""
//                checkoutResult!.breakdown.forEach({ (price) in
//                    princeInfo += "\(price.type): \(price.amount)\n"
//                })
//                self.finalPriceLabel.text = "\(princeInfo)total: $\(checkoutResult!.finalPrice)"
//                self.buyButton.isEnabled = true
//                self.checkoutBundle = checkoutBundle
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orderId = self.orderId, segue.identifier == "showOrderDetails" {
            let orderDetailsViewController = segue.destination as! OrderDetailsViewController
            orderDetailsViewController.orderId = orderId
            orderDetailsViewController.product = product
        }
    }
   
}

// MARK: - UIPickerViewDataSource

extension ProductViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 20
    }

}

// MARK: - UIPickerViewDelegate

extension ProductViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        checkout()
    }
    
}
