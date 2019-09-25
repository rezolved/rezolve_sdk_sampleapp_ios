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
    private var checkoutOrder: Order?
    private var orderId: String? = nil
    private var checkoutBundleV2: CheckoutBundleV2? = nil
    
    private var card: PaymentCard?
    private var phone: Phone?
    private var address: Address?
    private var checkoutProduct: CheckoutProduct?
    
    // MARK: - Public properties
    
    var scannedProduct: Product!
    
     // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sepupUI()
        configurePicker()
        checkout()
    }
    
    // MARK: - User Interactions
    
    @IBAction private func buyClick(_ sender: Any) {
        let location = Location(longitude: 80.0, latitude: 80.0)
        rezolveSession.checkoutManager.buyProduct(merchantId: scannedProduct.merchantId,
                                                  checkoutProduct: checkoutProduct!,
                                                  address: address!,
                                                  paymentRequest: PaymentRequest(paymentCard: card!, cvv: "123"),
                                                  location: location as? RezolveLocation,
                                                  phone: phone!,
                                                  
        callback: { checkoutOrder in
            self.orderId = checkoutOrder.id
            self.performSegue(withIdentifier: "showOrderDetails", sender: self)
        }, errorCallback: { error in
            print(error)
        })
        
    }
    
    // MARK: - Helper methods
    
    private func sepupUI() {
        navigationItem.title = scannedProduct.title
        priceLabel.text = "$\(scannedProduct.price)"
        imageView.imageFromUrl(urlString: scannedProduct.images[0])
        
        if let attributedString = try? NSAttributedString(data: Data(scannedProduct.description.utf8),
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
        
        let checkoutProduct = CheckoutProduct(id: scannedProduct.id,
                                              qty: Decimal(quantityPicker.selectedRow(inComponent: 0) + 1),
                                              productPlacement: placement,
                                              configurableOptions: [],
                                              customOptions: [])
        
        rezolveSession.paymentOptionManager.getProductOptions(checkoutProduct: checkoutProduct,
            merchantId: scannedProduct.merchantId,
            callback: { newPaymentOption in
                self.createPhone(checkoutProduct, newPaymentOption)
                
            }, errorCallback: { error in
               print(error)
        })
        
    }

    private func createPhone(_ product: CheckoutProduct, _ option: PaymentOption) {
        
        rezolveSession.phonebookManager.getAll(callback: { phones in
            self.createAddress(phones[0], product, option)
            
        }, errorCallback: { error in
            print(error)
        })
    }

    private func createAddress(_ phone: Phone, _ product: CheckoutProduct, _ option: PaymentOption) {
        let address = Address()
        address.id = ""
        address.shortName = "John Smith"
        address.line1 = "Lambeth"
        address.line2 = ""
        address.city = "London"
        address.state = ""
        address.zip = "SE1 7PB"
        address.country = "GB"
        address.phoneID = phone.id
        
        rezolveSession.addressbookManager.create(address: address, callback: { newAddress in
            self.createCard(phone, newAddress, product, option)
            
        }, errorCallback: { error in
            print(error)
        })
    }

    private func createCard(_ phone: Phone, _ address: Address, _ product: CheckoutProduct, _ option: PaymentOption) {
        let validationErrorCallback: (Array<String>) -> Void = { errors in
            print(errors)
        }
        
        let paymentCard = PaymentCard(id: "",
                                      type: "debit",
                                      cardHolderName: "John Curtis",
                                      expiresOn: "0817",
                                      validFrom: "0817",
                                      brand: "visa",
                                      addressId: address.id,
                                      shortName: "black amex",
                                      pan4: "1234",
                                      pan6: "123456",
                                      pan: "123456")
        
        
        
        rezolveSession.walletManager.create(paymentCard: paymentCard, callback: { newPaymentCard in
            self.card = newPaymentCard
            self.checkout(phone, address, product, option, PaymentRequest(paymentCard: newPaymentCard, cvv: "123"))
            
        }, validationErrorCallback: validationErrorCallback,
           errorCallback: { error in
            print(error)
        })
    }

    private func checkout(_ phone: Phone, _ address: Address, _ product: CheckoutProduct, _ option: PaymentOption, _ paymentRequest: PaymentRequest) {
        
        self.phone = phone
        self.address = address
        self.checkoutProduct = product
        
        let location = Location(longitude: 80.0, latitude: 80.0)
        let freePaymentMethod = (option.supportedPaymentMethods.first)?.type == "free"
        let deliveryMethod = freePaymentMethod ? nil : DeliveryMethod(addressId: address.id, type: "flatrate")
        
        let checkoutBundle = createProductCheckoutBundleV2(checkoutProduct: product,
                                                           deliveryMethod: deliveryMethod,
                                                           merchantId: scannedProduct.merchantId,
                                                           optionId: option.id,
                                                           paymentMethod: option.supportedPaymentMethods.first,
                                                           phoneId: phone.id,
                                                           location: location as? RezolveLocation)
        
        rezolveSession.checkoutManagerV2.checkout(bundle: checkoutBundle, callback: { order in
            self.checkoutOrder = order
            var princeInfo = ""
            order.breakdown.forEach({ (price) in
                princeInfo += "\(price.type): \(price.amount)\n"
            })
            self.finalPriceLabel.text = "\(princeInfo)total: $\(order.finalPrice)"
            self.buyButton.isEnabled = true
            self.checkoutBundleV2 = checkoutBundle
        }, errorCallback: { error in
            print(error)
        })
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orderId = self.orderId, segue.identifier == "showOrderDetails" {
            let orderDetailsViewController = segue.destination as! OrderDetailsViewController
            orderDetailsViewController.orderId = orderId
            orderDetailsViewController.product = scannedProduct
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
