import UIKit
import RezolveSDKLite

class ProductViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var quantityPicker: UIPickerView!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var finalPriceLabel: UILabel!
    
    // Class variables
    private var orderId: String? = nil
    private var checkoutBundle: CheckoutBundle? = nil
    var product: Product!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = product.title
        
        let description = product.description ?? ""
        
        let modifiedFont = String(format:"<span style=\"font-family: 'AvenirNext-Regular'; font-size: 14px\">%@</span>", description)
        if let attributedString = try? NSAttributedString(data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            descriptionLabel.attributedText = attributedString
        }
        
        priceLabel.text = "$\(product.price.toDouble.rounded(toPlaces: 2))"
        imageView.imageFromUrl(url: product.images[0])
        quantityPicker.delegate = self
        quantityPicker.dataSource = self
        checkout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orderId = self.orderId, segue.identifier == "showOrderDetails" {
            let orderDetailsViewController = segue.destination as! OrderDetailsViewController
            orderDetailsViewController.orderId = orderId
            orderDetailsViewController.product = product
        }
    }
    
    // MARK: - Private methods
    
    private func createPhone(_ product: CheckoutProduct, _ option: PaymentOption) {
        RezolveService.session?.phonebookManager.getAll { [weak self] result in
            switch result {
            case .success(let phones):
                if phones.indices.contains(0) {
                    self?.createAddress(phones[0], product, option)
                }
                else {
                    let phone = Phone(name: "user_phone", phone: "+443069510069")
                    RezolveService.session?.phonebookManager.create(phoneToCreate: phone,
                                                                    completionHandler: { [weak self] _ in
                        self?.createAddress(phone, product, option)
                    })
                }
            case .failure(let error):
                print("Create phone error -> \(error)")
            }
        }
    }
    
    private func createAddress(_ phone: Phone, _ product: CheckoutProduct, _ option: PaymentOption) {
        let address = Address(id: "",
                              fullName: "John Smith",
                              shortName: "JS",
                              line1: "Lambeth",
                              line2: "",
                              city: "London",
                              state: "",
                              zip: "SE1 7PB",
                              country: "GB",
                              phoneId: phone.id)
        
        RezolveService.session?.addressbookManager.create(address: address) { [weak self] result in
            switch result {
            case .success(let address):
                self?.createCard(phone, address, product, option)
                
            case .failure(let error):
                print("Create address error -> \(error)")
            }
        }
    }
    
    private func createCard(_ phone: Phone, _ address: Address, _ product: CheckoutProduct, _ option: PaymentOption) {
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
        
        RezolveService.session?.walletManager.create(paymentCard: paymentCard) { [weak self] result in
            switch result {
            case .success(let card):
                self?.checkout(phone, address, product, option, PaymentRequest(paymentCard: card, cvv: "123"))
                
            case .failure(let error):
                print("Create credit card error -> \(error)")
            }
        }
    }
    
    private func checkout(_ phone: Phone,
                          _ address: Address,
                          _ product: CheckoutProduct,
                          _ option: PaymentOption,
                          _ paymentRequest: PaymentRequest) {
        
        let freePaymentMethod = (option.supportedPaymentMethods?.first)?.type == "free"
        let shippingMethod = freePaymentMethod ? nil : CheckoutShippingMethod(type: "flatrate", addressId: address.id)
        let location = Location(longitude: 80.0, latitude: 80.0)
        
        let checkoutBundle = CheckoutBundle(
                checkoutProduct: product,
                shippingMethod: shippingMethod,
                merchantId: self.product.merchantId,
                optionId: option.id,
                paymentMethod: option.supportedPaymentMethods?.first,
                paymentRequest: paymentRequest,
                ecPayPaymentRequest: nil,
                phoneId: phone.id,
                location: location
        )
        
        RezolveService.session?.checkoutManager.checkout(bundle: checkoutBundle) { [weak self] result in
            switch result {
            case .success(let checkoutResult):
                var princeInfo = ""
                checkoutResult.breakdown.forEach({ (price) in
                    princeInfo += "\(price.type.uppercaseFirstLetter): $\(price.amount.toDouble.rounded(toPlaces: 2))\n"
                })
                self?.finalPriceLabel.text = "\(princeInfo)Total: $\(checkoutResult.finalPrice.rounded(toPlaces: 2))"
                self?.buyButton.isEnabled = true
                self?.checkoutBundle = checkoutBundle
                
            case .failure(let error):
                print("Checkout error -> \(error)")
            }
        }
    }
    
    private func checkout() {
        finalPriceLabel.text = "Loading..."
        buyButton.isEnabled = false
        let checkoutProduct = CheckoutProduct(id: product.id,
                                              quantity: Decimal(quantityPicker.selectedRow(inComponent: 0) + 1))
        
        RezolveService.session?.paymentOptionManager.getPaymentOptionFor(checkoutProduct: checkoutProduct,
                                                                        merchantId: product.merchantId) { [weak self] result in
            switch result {
            case .success(let option):
                self?.createPhone(checkoutProduct, option)
                
            case .failure(let error):
                print("Get options error -> \(error)")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func buyClick(_ sender: Any) {
        RezolveService.session?.checkoutManager.buy(bundle: checkoutBundle!, paymentPayload: nil) { [weak self] result in
            switch result {
            case .success(let order):
                self?.orderId = order.id
                self?.performSegue(withIdentifier: "showOrderDetails", sender: self)
                
            case .failure(let error):
                print("Purchase error -> \(error)")
            }
        }
    }
}

extension ProductViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 9
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 15.0)!
        label.textAlignment = .center
        label.text = "\(String(row + 1)) item(s)"
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        checkout()
    }
}
