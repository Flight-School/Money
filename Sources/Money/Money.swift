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
        var approximate = self.amount
        var rounded = Decimal()
        NSDecimalRound(&rounded, &approximate, Currency.minorUnit, .bankers)
        
        return Money<Currency>(rounded)
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
        var approximate = Decimal(floatLiteral: value)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &approximate, Currency.minorUnit, .bankers)
        self.init(rounded)
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

extension Money: Codable {
    private enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode
    }

    public init(from decoder: Decoder) throws {
        if let keyedContainer = try? decoder.container(keyedBy: CodingKeys.self) {
            let currencyCode = try keyedContainer.decode(String.self, forKey: .currencyCode)
            guard currencyCode == Currency.code else {
                let context = DecodingError.Context(codingPath: keyedContainer.codingPath, debugDescription: "Currency mismatch: expected \(Currency.code), got \(currencyCode)")
                throw DecodingError.typeMismatch(Money<Currency>.self, context)
            }
            self.amount = try keyedContainer.decode(Decimal.self, forKey: .amount)
        } else if let singleValueContainer = try? decoder.singleValueContainer() {
            self.amount = try singleValueContainer.decode(Decimal.self)
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
