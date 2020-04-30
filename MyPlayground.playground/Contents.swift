import Foundation

class VendingMachineProduct {
    var name: String
    var amount: Int
    var price: Double
    
    init(name: String, amount: Int, price: Double) {
        self.name = name
        self.amount = amount
        self.price = price
    }
    
    
}

enum VendingMachineError: Error {
    case productNotFound
    case productOutOfStock
    case insufficientMoney
    case failedToDeliverTheProduct

}

extension VendingMachineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToDeliverTheProduct:
            return "falhou ao entregar o produto"
        case .productNotFound:
            return "produto não encontrado"
        case .productOutOfStock:
            return "produto fora de estoque"
        case .insufficientMoney:
            return "dinheiro insuficiente"
        }
    }
}

//TODO: Definir os erros

class VendingMachine {
    private var estoque: [VendingMachineProduct]
    private var money: Double
    
    init(products: [VendingMachineProduct]) {
        self.estoque = products
        self.money = 0
    }
    
    func buyProduct(name: String, with money: Double, completionHandler: @escaping (Result<VendingMachineProduct, Error>) -> Void) {
        
        self.money = money
        let prouctOptional = estoque.first { (product) -> Bool in
            return product.name == name
        }
        
        guard let produto = prouctOptional else { 
            return completionHandler(.failure(VendingMachineError.productNotFound))
        }
        
        guard produto.amount > 0 else { 
            return  completionHandler(.failure(VendingMachineError.productOutOfStock))
        }
        
        guard produto.price <= self.money else {
            return completionHandler(.failure(VendingMachineError.insufficientMoney))
        }
        
        self.money -= produto.price 
        produto.amount -= 1
        
        if Int.random(in: 0...100) < 10 {
            return completionHandler(.failure(VendingMachineError.failedToDeliverTheProduct))
        }
        
        completionHandler(.success(produto))
        
    }
    
    
    func getProduct(named name: String, with money: Double) throws {
        self.money = money
        let produtoOptional = estoque.first { (produto) -> Bool in
            return produto.name == name
        }
        guard let produto = produtoOptional else { throw
            VendingMachineError.productNotFound
        }
        guard produto.amount > 0 else { throw  
            VendingMachineError.productOutOfStock
        }
        guard produto.price <= self.money else { throw
            VendingMachineError.insufficientMoney
        }
        self.money -= produto.price
        produto.amount -= 1
        let troco = getTroco(amount: self.money, price: produto.price)
        if Int.random(in: 0...100) < 10 { throw
            VendingMachineError.failedToDeliverTheProduct
        }
    }
    
    func getTroco(amount: Double, price: Double) -> Double {
        
        let change = amount - price
        
        return change
    }
}

let vendingMachine = VendingMachine(products: [VendingMachineProduct(name: "Carregador de Iphone Original", amount: 10, price: 140.0), VendingMachineProduct(name: "Umbrella", amount: 15, price: 20.0)])

do {
    try vendingMachine.getProduct(named: "Umbrella", with: 10.0)
} catch {
    print(error.localizedDescription)
}

do {
    vendingMachine.buyProduct(name: "Umbrella", with: 10.0, completionHandler: { (result) in
        switch result {
        case .success(let product):
            print(product.name)
        case .failure(let error):
            print(error.localizedDescription)
        }
    })
}
    

