import UIKit
import RezolveSDK

final class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var category: RezolveSDK.Category!
    var merchantID: String!
    
    private var productToShow: Product?
    
    enum Item {
        case category(RezolveSDK.Category)
        case product(RezolveSDK.DisplayProduct)
    }
    
    var items: [Item] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = category.name
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadCategoryAndProducts()
    }
    
    private func loadCategoryAndProducts() {
        guard
            let category = category,
            let merchantID = merchantID,
            let session = RezolveService.session
        else {
            return
        }
        session.productManager.getPaginatedCategoriesAndProducts(merchantId: merchantID, categoryId: category.id, pageNavigationFilters: nil) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
            case .success(let category):
                self.setupItems(category: category)
            }
        }
    }
    
    private func setupItems(category: RezolveSDK.Category) {
        let categories = category.categories?.items.map({ Item.category($0) }) ?? []
        let products = category.products?.items.map({ Item.product($0) }) ?? []
        
        items = categories + products
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item {
        case .category(let category):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.name = category.name
            return cell
        case .product(let product):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.name = product.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item {
        case .category(let category):
            showCategory(category: category)
        case .product(let product):
            loadProduct(product: product)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showCategory(category: RezolveSDK.Category) {
        let categoryViewController = storyboard?.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
        categoryViewController.category = category
        categoryViewController.merchantID = merchantID
        navigationController?.pushViewController(categoryViewController, animated: true)
    }
    
    private func loadProduct(product: DisplayProduct) {
        let product = RezolveSDK.Product(
            id: product.id,
            merchantId: merchantID,
            title: "",
            subtitle: "",
            price: 0,
            originalPrice: nil,
            currencySymbol: nil,
            description: "",
            maximumQuantity: 0,
            isVirtual: false,
            isAct: false,
            images: [],
            imageThumbnails: [],
            options: [],
            priceOptions: [],
            availableOptions: [],
            customOptions: [],
            additionalAttributes: [],
            categoryPlacement: CategoryPlacement(adId: nil, placementId: nil)
        )
        RezolveService.session?.productManager.getProductDetails(
            merchantId: merchantID,
            categoryId: category.id, product: product
        ) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
            case .success(let product):
                self.productToShow = product
                self.performSegue(withIdentifier: "showProduct", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let productViewController = segue.destination as? ProductViewController {
            productViewController.product = productToShow
        }
    }
}

final class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    var name: String = "" {
        didSet {
            categoryNameLabel.text = "Category: \(name)"
        }
    }
}

final class ProductCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    
    var name: String = "" {
        didSet {
            productNameLabel.text = "Product: \(name)"
        }
    }
}
