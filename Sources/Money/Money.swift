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

// MARK: - Comparable

extension Money: Comparable {
    public static func < (lhs: Money<Currency>, rhs: Money<Currency>) -> Bool {
        return lhs.amount < rhs.amount
    }
}

// MARK: - AdditiveArithmetic

#if swift(>=5.0)
extension Money: AdditiveArithmetic {}
#endif

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

extension Money {
    /// Subtracts one monetary amount from another.
    public static prefix func - (value: Money<Currency>) -> Money<Currency> {
        return Money<Currency>(-value.amount)
    }
}

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

// MARK: - CustomStringConvertible

extension Money: CustomStringConvertible {
    public var description: String {
        return "\(self.amount)"
    }
}

// MARK: - LosslessStringConvertible

extension Money: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let amount = Decimal(string: description) else {
            return nil
        }

        self.init(amount)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Money: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(Decimal(integerLiteral: value))
    }
}

// MARK: - ExpressibleByFloatLiteral

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

// MARK: - ExpressibleByStringLiteral

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

// MARK: - Codable

extension CodingUserInfoKey {
    /**
     The key for specifying custom decoding options for `Money` values.

     This user info key should be associated with
     an `MoneyDecodingOptions` object.

     - SeeAlso: `JSONDecoder.moneyDecodingOptions`
     */
    public static let moneyDecodingOptions = CodingUserInfoKey(rawValue: "com.flightschool.money.decoding-options")!

    /**
     The key for specifying custom encoding options for `Money` values.

     This user info key should be associated with
     an `MoneyEncodingOptions` object.

     - SeeAlso: `JSONDecoder.moneyEncodingOptions`
     */
    public static let moneyEncodingOptions = CodingUserInfoKey(rawValue: "com.flightschool.money.encoding-options")!
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
    public static let requireExplicitCurrency = MoneyDecodingOptions(rawValue: 1 << 0)

    /**
     Throws an error when attempting to decode
     `amount` from a floating-point number.

     - Important: Foundation decoders currently decode number values
                  using a binary floating-point number type,
                  which cannot precisely express certain values.
                  Specify this option to require monetary amounts
                  to be decoded precisely from string representations.
     - Bug: See https://bugs.swift.org/browse/SR-7054.
     */
    public static let requireStringAmount = MoneyDecodingOptions(rawValue: 1 << 1)

    /**
     Rounds `amount` to the number of places of the minor currency unit
     when decoding from a floating-point number.
     */
    public static let roundFloatingPointAmount = MoneyDecodingOptions(rawValue: 1 << 2)
}

/**
 Custom encoding options for `Money` values.

 Configure the encoding behavior either
 by using the `JSONDecoder.moneyEncodingOptions` property
 or by setting the `CodingUserInfoKey.moneyEncodingOptions` key
 in the encoder's `userInfo` property.
 */
public struct MoneyEncodingOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /**
     Encodes the `Money` value as a single value,
     without specifying a currency.
     */
    public static let omitCurrency = MoneyEncodingOptions(rawValue: 1 << 0)


    /**
     Encodes the string representation of `amount`
     instead of the built-in `Decimal` encoding.
    */
    public static let encodeAmountAsString = MoneyEncodingOptions(rawValue: 1 << 1)
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
            } else if !options.contains(.requireStringAmount) {
                amount = try keyedContainer.decode(Decimal.self, forKey: .amount)
                if options.contains(.roundFloatingPointAmount) {
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
            } else if !options.contains(.requireStringAmount) {
                amount = try singleValueContainer.decode(Decimal.self)
                if options.contains(.roundFloatingPointAmount) {
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
        let options = encoder.userInfo[.moneyEncodingOptions] as? MoneyEncodingOptions ?? []

        if options.contains(.omitCurrency) {
            var singleValueContainer = encoder.singleValueContainer()
            if options.contains(.encodeAmountAsString) {
                try singleValueContainer.encode(self.amount.description)
            } else {
                try singleValueContainer.encode(self.amount)
            }
        } else {
            var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
            try keyedContainer.encode(Currency.code, forKey: .currencyCode)
            if options.contains(.encodeAmountAsString) {
                try keyedContainer.encode(self.amount.description, forKey: .amount)
            } else {
                try keyedContainer.encode(self.amount, forKey: .amount)
            }
        }
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
