import Foundation

/// An amount of money in a given currency.
public struct Money<Currency: CurrencyType>: Equatable, Hashable {
    /// The amount of money.
    public var amount: Decimal

    /// Creates an amount of money with a given decimal number.
    public init(_ amount: Decimal) {
        self.amount = amount
    }

    /// The currency type.
    public var currency: CurrencyType.Type {
        return Currency.self
    }
    
    /**
        A monetary amount rounded to
        the number of places of the minor currency unit.
     */
    public var rounded: Money<Currency> {
        return Money<Currency>(amount.rounded(for: Currency.self))
    }
}

extension Money: Comparable {
    public static func < (lhs: Money<Currency>, rhs: Money<Currency>) -> Bool {
        return lhs.amount < rhs.amount
    }
}

extension Money: CustomStringConvertible {
    public var description: String {
        return "\(self.amount)"
    }
}

extension Money: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let amount = Decimal(string: description) else {
            return nil
        }

        self.init(amount)
    }
}

extension Money: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(Decimal(integerLiteral: value))
    }
}

extension Money: ExpressibleByFloatLiteral {
    /**
     Creates a new value from the given floating-point literal.
     
     - Important: Swift floating-point literals are currently initialized
                  using binary floating-point number type,
                  which cannot precisely express certain values.
                  As a workaround, monetary amounts initialized
                  from a floating-point literal are rounded
                  to the number of places of the minor currency unit.
                  To express a smaller fractional monetary amount,
                  initialize from a string literal or decimal value instead.
     - Bug: See https://bugs.swift.org/browse/SR-920
    */
    public init(floatLiteral value: Double) {
        self.init(Decimal(floatLiteral: value).rounded(for: Currency.self))
    }
}

extension Money: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: Unicode.Scalar) {
        self.init(stringLiteral: String(value))
    }

    public init(extendedGraphemeClusterLiteral value: Character) {
        self.init(stringLiteral: String(value))
    }

    public init(stringLiteral value: String) {
        self.init(value)!
    }
}

extension Money {
    /// The sum of two monetary amounts.
    public static func + (lhs: Money<Currency>, rhs: Money<Currency>) -> Money<Currency> {
        return Money<Currency>(lhs.amount + rhs.amount)
    }

    /// Adds one monetary amount to another.
    public static func += (lhs: inout Money<Currency>, rhs: Money<Currency>) {
        lhs.amount += rhs.amount
    }

    /// The difference between two monetary amounts.
    public static func - (lhs: Money<Currency>, rhs: Money<Currency>) -> Money<Currency> {
        return Money<Currency>(lhs.amount - rhs.amount)
    }

    /// Subtracts one monetary amount from another.
    public static func -= (lhs: inout Money<Currency>, rhs: Money<Currency>) {
        lhs.amount -= rhs.amount
    }
}

#if swift(>=5.0)
extension Money: AdditiveArithmetic {}
#endif

extension Money {
    /// The product of a monetary amount and a scalar value.
    public static func * (lhs: Money<Currency>, rhs: Decimal) -> Money<Currency> {
        return Money<Currency>(lhs.amount * rhs)
    }

    /**
        The product of a monetary amount and a scalar value.
     
        - Important: Multiplying a monetary amount by a floating-point number
                     results in an amount rounded to the number of places
                     of the minor currency unit.
                     To produce a smaller fractional monetary amount,
                     multiply by a `Decimal` value instead.
     */
    public static func * (lhs: Money<Currency>, rhs: Double) -> Money<Currency> {
        return (lhs * Decimal(rhs)).rounded
    }

    /// The product of a monetary amount and a scalar value.
    public static func * (lhs: Money<Currency>, rhs: Int) -> Money<Currency> {
        return lhs * Decimal(rhs)
    }

    /// The product of a monetary amount and a scalar value.
    public static func * (lhs: Decimal, rhs: Money<Currency>) -> Money<Currency> {
        return rhs * lhs
    }

    /**
        The product of a monetary amount and a scalar value.
     
        - Important: Multiplying a monetary amount by a floating-point number
                     results in an amount rounded to the number of places
                     of the minor currency unit.
                     To produce a smaller fractional monetary amount,
                     multiply by a `Decimal` value instead.
     */
    public static func * (lhs: Double, rhs: Money<Currency>) -> Money<Currency> {
        return rhs * lhs
    }

    /// The product of a monetary amount and a scalar value.
    public static func * (lhs: Int, rhs: Money<Currency>) -> Money<Currency> {
        return rhs * lhs
    }

    /// Multiplies a monetary amount by a scalar value.
    public static func *= (lhs: inout Money<Currency>, rhs: Decimal) {
        lhs.amount *= rhs
    }

    /// Multiplies a monetary amount by a scalar value.
    /**
        Multiplies a monetary amount by a scalar value.
     
        - Important: Multiplying a monetary amount by a floating-point number
                     results in an amount rounded to the number of places
                     of the minor currency unit.
                     To produce a smaller fractional monetary amount,
                     multiply by a `Decimal` value instead.
     */
    public static func *= (lhs: inout Money<Currency>, rhs: Double) {
        lhs.amount = Money<Currency>(lhs.amount * Decimal(rhs)).rounded.amount
    }

    /// Multiplies a monetary amount by a scalar value.
    public static func *= (lhs: inout Money<Currency>, rhs: Int) {
        lhs.amount *= Decimal(rhs)
    }
}

extension Money {
    /// Subtracts one monetary amount from another.
    public static prefix func - (value: Money<Currency>) -> Money<Currency> {
        return Money<Currency>(-value.amount)
    }
}

// MARK: -

extension CodingUserInfoKey {
    /**
     The key for specifying custom decoding options for `Money` values.

     This user info key should be associated with
     an `MoneyDecodingOptions` object.

     - SeeAlso: `JSONDecoder.moneyDecodingOptions`
     */
    public static let moneyDecodingOptions = CodingUserInfoKey(rawValue: "com.flightschool.money.decoding-options")!
}

/**
 Custom decoding options for `Money` values.

 Configure the decoding behavior either
 by using the `JSONDecoder.moneyDecodingOptions` property
 or by setting the `CodingUserInfoKey.moneyDecodingOptions` key
 in the decoder's `userInfo` property.
 */
public struct MoneyDecodingOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /**
     Throws a `DecodingError` when attempting to decode
     a `Money` value from a string or number value.

     By default, `Money` values are decoded from single values
     using the associated `Currency` type.
     */
    public static let requireExplicitCurrency = MoneyDecodingOptions(rawValue: 1 << 1)

    /**
     Throws an error when attempting to decode
     `amount` from a floating-point number.

     - Important: Foundation decoders currently decode number values
                  using binary floating-point number type,
                  which cannot precisely express certain values.
                  Monetary amounts can, however,
                  be precisely decoded from string values.
     - Bug: See https://bugs.swift.org/browse/SR-7054.
     */
    public static let requireStringAmounts = MoneyDecodingOptions(rawValue: 1 << 2)

    /**
     Rounds `amount` to the number of places of the minor currency unit
     when decoding from a floating-point number.
     */
    public static let roundFloatingPointAmounts = MoneyDecodingOptions(rawValue: 1 << 3)
}

extension Money: Codable {
    private enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode
    }

    public init(from decoder: Decoder) throws {
        let options = decoder.userInfo[.moneyDecodingOptions] as? MoneyDecodingOptions ?? []
        if let keyedContainer = try? decoder.container(keyedBy: CodingKeys.self) {
            let currencyCode = try keyedContainer.decode(String.self, forKey: .currencyCode)
            guard currencyCode == Currency.code else {
                let context = DecodingError.Context(codingPath: keyedContainer.codingPath, debugDescription: "Currency mismatch: expected \(Currency.code), got \(currencyCode)")
                throw DecodingError.typeMismatch(Money<Currency>.self, context)
            }

            var amount: Decimal?
            if let string = try? keyedContainer.decode(String.self, forKey: .amount) {
                amount = Decimal(string: string)
            } else if !options.contains(.requireStringAmounts) {
                amount = try keyedContainer.decode(Decimal.self, forKey: .amount)
                if options.contains(.roundFloatingPointAmounts) {
                    amount = amount?.rounded(for: Currency.self)
                }
            }

            if let amount = amount {
                self.amount = amount
            } else {
                throw DecodingError.dataCorruptedError(forKey: .amount, in: keyedContainer, debugDescription: "Couldn't decode Decimal value for amount")
            }
        } else if !options.contains(.requireExplicitCurrency),
            let singleValueContainer = try? decoder.singleValueContainer()
        {
            var amount: Decimal?
            if let string = try? singleValueContainer.decode(String.self) {
                amount = Decimal(string: string)
            } else if !options.contains(.requireStringAmounts) {
                amount = try singleValueContainer.decode(Decimal.self)
                if options.contains(.roundFloatingPointAmounts) {
                    amount = amount?.rounded(for: Currency.self)
                }
            }

            if let amount = amount {
                self.amount = amount
            } else {
                throw DecodingError.dataCorruptedError(in: singleValueContainer, debugDescription: "Couldn't decode Decimal value for amount")
            }
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Couldn't decode Money value")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
        try keyedContainer.encode(self.amount, forKey: .amount)
        try keyedContainer.encode(Currency.code, forKey: .currencyCode)
    }
}

// MARK: -

fileprivate extension Decimal {
    func rounded(for currency: CurrencyType.Type) -> Decimal {
        var approximate = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &approximate, currency.minorUnit, .bankers)

        return rounded
    }
}
