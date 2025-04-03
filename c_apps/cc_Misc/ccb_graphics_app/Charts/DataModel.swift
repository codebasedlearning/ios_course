// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

struct Sales: Identifiable {
    let id = UUID()
    let year: Int
    let amount: Int
}

struct Product: Identifiable {
    let id = UUID()
    var name: String
    var sales: [Sales]
}

@Observable
class SalesData {
    var sales: [Product]
    
    init() {
        self.sales = []
        self.sales.append(contentsOf: [
            Product(name: "Cars", sales: generateRandomSalesData()),
            Product(name: "Ships", sales: generateRandomSalesData())
        ])
    }
    
    func generateRandomSalesData() -> [Sales] {
        var sales: [Sales] = []
        for year in 2001...2024 {
            sales.append(Sales(year: year, amount: Int.random(in: 3500...4500)))
        }
        return sales
    }
}
