import Foundation

extension JSONEncoder {
    public var moneyEncodingOptions: [MoneyEncodingOptions] {
        get {
            return userInfo[.moneyEncodingOptions] as? [MoneyEncodingOptions] ?? []
        }

        set {
            userInfo[.moneyEncodingOptions] = newValue
        }
    }
}
