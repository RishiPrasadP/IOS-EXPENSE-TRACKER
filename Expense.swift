import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var category: Category
    
    enum Category: String, Codable, CaseIterable {
        case housing = "Housing"
        case food = "Food"
        case clothing = "Clothing"
        case transportation = "Transportation"
        case education = "Education"
        
        var icon: String {
            switch self {
            case .housing: return "house.fill"
            case .food: return "fork.knife"
            case .clothing: return "tshirt.fill"
            case .transportation: return "car.fill"
            case .education: return "book.fill"
            }
        }
    }
} 