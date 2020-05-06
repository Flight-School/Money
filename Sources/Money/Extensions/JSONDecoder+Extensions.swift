import Foundation

extension JSONDecoder {
    public var moneyDecodingOptions: MoneyDecodingOptions {
        get {
            return userInfo[.moneyDecodingOptions] as? MoneyDecodingOptions ?? []
        }

        set {
            userInfo[.moneyDecodingOptions] = newValue
        }
    }
}
