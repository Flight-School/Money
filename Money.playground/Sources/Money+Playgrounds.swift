import Foundation
import Money

extension Money: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Currency.code
        
        return formatter.string(for: self.amount)!
    }
}
