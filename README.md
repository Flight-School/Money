# Money

[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Swift Version][swift version badge]][swift version]
![Cocoapods platforms][cocoapods platforms badge]
[![Cocoapods compatible][cocoapods badge]][cocoapods]
[![Carthage compatible][carthage badge]][carthage]

A precise, type-safe representation of monetary amounts in a given currency.

This functionality is discussed in Chapter 3 of
[Flight School Guide to Swift Numbers](https://flight.school/books/numbers).

## Requirements

- Swift 4.0+

## Installation

### Swift Package Manager

Add the Money package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/Flight-School/Money",
        from: "1.3.0"
    ),
  ]
)
```

Then run the `swift build` command to build your project.

### CocoaPods

You can install `Money` via CocoaPods,
by adding the following line to your `Podfile`:

```ruby
pod 'Money-FlightSchool', '~> 1.3.0'
```

Run the `pod install` command to download the library
and integrate it into your Xcode project.

> **Note**
> The module name for this library is "Money" ---
> that is, to use it, you add `import Money` to the top of your Swift code
> just as you would by any other installation method.
> The pod is called "Money-FlightSchool"
> because there's an existing pod with the name "Money".

### Carthage

To use `Money` in your Xcode project using Carthage,
specify it in `Cartfile`:

```
github "Flight-School/Money" ~> 1.3.0
```

Then run the `carthage update` command to build the framework,
and drag the built Money.framework into your Xcode project.

## Usage

### Creating Monetary Amounts

The `Money` type has a required associated `Currency` type.
These currency types are named according to their
three letter [ISO 4701][iso4217] currency codes.
You can initialize a monetary using a `Decimal` value:

```swift
let amount = Decimal(12)
let monetaryAmount = Money<USD>(amount)
```

Some currencies specify a minor unit.
For example, USD amounts are often expressed in cents,
each worth 1/100 of a dollar.
You can initialize monetary amounts from a quantity of minor units.
For currencies that don't have a minor unit,
such as JPY,
this is equivalent to the standard initializer.

```swift
let twoCents = Money<USD>(minorUnits: 2)
twoCents.amount // 0.02

let ichimonEn = Money<JPY>(minorUnits: 10_000)
ichimonEn.amount // 10000
```

You can also create monetary amounts using
integer, floating-point, and string literals.

```swift
12 as Money<USD>
12.00 as Money<USD>
"12.00" as Money<USD>
```

**Important**:
Swift floating-point literals are currently initialized
using binary floating-point number type,
which cannot precisely express certain values.
As a workaround, monetary amounts initialized
from a floating-point literal are rounded
to the number of places of the minor currency unit.
If you want to express a smaller fractional monetary amount,
initialize from a string literal or `Decimal` value instead.

```swift
let preciseAmount: Money<USD> = "123.4567"
let roundedAmount: Money<USD> = 123.4567

preciseAmount.amount // 123.4567
roundedAmount.amount // 123.46
```

For more information, see https://bugs.swift.org/browse/SR-920.

### Comparing Monetary Amounts

You can compare two monetary amounts with the same currency:

```swift
let amountInWallet: Money<USD> = 60.00
let price: Money<USD> = 19.99

amountInWallet >= price // true
```

Attempting to compare monetary amounts with different currencies
results in a compiler error:

```swift
let dollarAmount: Money<USD> = 123.45
let euroAmount: Money<EUR> = 4567.89

dollarAmount == euroAmount // Error: Binary operator '==' cannot be applied
```

### Adding, Subtracting, and Multiplying Monetary Amounts

Monetary amounts can be added, subtracted, and multiplied
using the standard binary arithmetic operators (`+`, `-`, `*`):

```swift
let prices: [Money<USD>] = [2.19, 5.39, 20.99, 2.99, 1.99, 1.99, 0.99]
let subtotal = prices.reduce(0.00, +) // "$36.53"
let tax = 0.08 * subtotal // "$2.92"
let total = subtotal + tax // "$39.45"
```

**Important**: Multiplying a monetary amount by a floating-point number
results in an amount rounded to the number of places
of the minor currency unit.
If you want to produce a smaller fractional monetary amount,
multiply by a `Decimal` value instead.

### Formatting Monetary Amounts

You can create a localized representation of a monetary amount
using `NumberFormatter`.
Set the `currencyCode` property of the formatter
to the `currency.code` property of the `Money` value
and pass the `amount` property to the formatter `string(for:)` method.

```swift
let allowance: Money<USD> = 10.00
let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.locale = Locale(identifier: "fr-FR")
formatter.currencyCode = allowance.currency.code
formatter.string(for: allowance.amount) // "10,00 $US"
```

### Encoding and Decoding Monetary Amounts

#### Encoding

By default,
`Money` values are encoded as keyed containers,
with `amount` encoded as a number value.

```swift
let value: Money<USD> = 123.45

let encoder = JSONEncoder()
let data = try encoder.encode(value)
String(data: data, encoding: .utf8) // #"{"amount":123.45,"currency":"USD"}"#
```

To configure encoding behavior,
set either the `JSONEncoder.moneyEncodingOptions` property
or the `CodingUserInfoKey.moneyEncodingOptions` key
in the encoder's `userInfo` property.

```swift
var encoder = JSONEncoder()
encoder.moneyEncodingOptions = [.omitCurrency, .encodeAmountAsString]

let data = try encoder.encode([value])
String(data: data, encoding: .utf8) // #"["123.45"]"#
```

#### Decoding

The default decoding behavior is flexible,
supporting both keyed and single value containers,
with string or number values for `amount`.

```swift
let json = #"""
[
    { "currency": "USD", "amount": "100.00" },
    50.00,
    "10"
]
"""#.data(using: .utf8)!

let decoder = JSONDecoder()
let values = try decoder.decode([Money<USD>].self, from: json)
values.first?.amount // 100.00
values.last?.currency.code // "USD"
```

To configure decoding behavior,
set either the `JSONDecoder.moneyDecodingOptions` property
or the `CodingUserInfoKey.moneyDecodingOptions` key
in the decoder's `userInfo` property.

```swift
var decoder = JSONDecoder()
decoder.moneyDecodingOptions = [.requireExplicitCurrency]
```

**Important**:
Foundation decoders currently decode number values
using a binary floating-point number type,
which cannot precisely express certain values.
As a workaround,
you can specify the `requireStringAmount` decoding option
to require monetary amounts to be
decoded precisely from a string representation.

```swift
let json = #"""
{ "currency": "USD", "amount": "27.31" }
"""#.data(using: .utf8)!

var decoder = JSONDecoder()

try decoder.decode(Money<USD>.self, from: json) // DecodingError

decoder.moneyDecodingOptions = [.requireStringAmount]
let preciseAmount = try decoder.decode(Money<USD>.self, from: json)
preciseAmount.amount // 27.31
```

Alternatively,
you can the `roundFloatingPointAmount` decoding option
to round decoded floating-point values
to the number of places of the minor currency unit.

```swift
let json = #"""
{ "currency": "USD", "amount": 27.31 }
"""#.data(using: .utf8)!

var decoder = JSONDecoder()

let impreciseAmount = try decoder.decode(Money<USD>.self, from: json)
impreciseAmount.amount // 27.30999999...

decoder.moneyDecodingOptions = [.roundFloatingPointAmount]
let roundedAmount = try decoder.decode(Money<USD>.self, from: json)
roundedAmount.amount // 27.31
```

For more information, see https://bugs.swift.org/browse/SR-7054.

### Supporting Multiple Currencies

Consider a `Product` structure with a `price` property.
If you only support a single currency, such as US Dollars,
you would define `price` to be of type `Money<USD>`:

```swift
struct Product {
    var price: Money<USD>
}
```

If you want to support multiple currencies, however,
you can't specify an explicit currency type in the property declaration.
Instead, the `Product` would have to be defined as a generic type:

```swift
struct Product<Currency: CurrencyType> {
    var price: Money<Currency>
}
```

Unfortunately, this approach is unwieldy,
as each type that interacts with `Product` would also need to be generic,
and so on, until the entire code base is generic over the currency type.

```swift
class ViewController<Currency: CurrencyType> : UIViewController { ... } // 😭
```

A better solution would be to define a new `Price` protocol
with requirements that match the `Money` type:

```swift
protocol Price {
    var amount: Decimal { get }
    var currency: CurrencyType.Type { get }
}

extension Money: Price {}
```

Doing this allows prices to be defined in multiple currencies
without making `Product` generic over the currency type:

```swift
struct Product {
    var price: Price
}

let product = Product(price: 12.00 as Money<USD>)
product.price // "$12.00"
```

If you want to support only certain currencies, such as US Dollars and Euros,
you can define a `SupportedCurrency` protocol
and add conformance to each currency type through an extension:

```swift
protocol SupportedCurrency: CurrencyType {}
extension USD: SupportedCurrency {}
extension EUR: SupportedCurrency {}

extension Money: Price where Currency: SupportedCurrency {}
```

Now, attempting to create a `Product` with a price in an unsupported currency
results in a compiler error:

```swift
Product(price: 100.00 as Money<EUR>)
Product(price: 100.00 as Money<GBP>) // Error
```

#### Supported Currencies

This package provides a `Currency` type for
each of the currencies defined by the [ISO 4217][iso4217] standard
with the exception of special codes,
such as USN (US Dollar, Next day) and
XBC (Bond Markets Unit European Unit of Account 9).

The [source file][currency.swift] defining the available currencies
is generated from a [CSV file][iso4217.csv] using [GYB][gyb].
This data source is up-to-date with
[ISO 4217 Amendment Number 169](https://www.currency-iso.org/en/shared/amendments/iso-4217-amendment.html),
published on August 17, 2018.

You can regenerate `Sources/Money/Currency.swift` from `Resources/iso4217.csv`
by installing [GYB][gyb]
and running the `make` command from the terminal:

```terminal
$ make
```

> We don't currently have a mechanism to automatically update this data source.
> Please [open an issue](https://github.com/Flight-School/Money/issues/new)
> if you're aware of any new amendments made to ISO 4217.

You can lookup any built-in currency types by its three-letter code
using the `iso4217Currency(for:)` function.

```swift
iso4217Currency(for: "USD")?.name // "US Dollar"
iso4217Currency(for: "invalid") // nil
```

### Adding Custom Currencies

You can create your own custom currency types by defining an enumeration
that conforms to the `CurrencyType` protocol.
For example, here's how you might represent Bitcoin (BTC):

```swift
enum BTC: CurrencyType {
    static var name: String { return "Bitcoin" }
    static var code: String { return "BTC" }
    static var minorUnit: Int { return 8 }
}

let satoshi: Money<BTC> = 0.00000001
```

`NumberFormatter` only supports currencies defined by ISO 4217,
so you'll have to configure the symbol, currency code,
and any other necessary parameters:

```swift
let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.currencySymbol = "₿"
formatter.currencyCode = "BTC"
formatter.maximumFractionDigits = 8

formatter.string(for: satoshi.amount) // ₿0.00000001
```

> **Important**:
> The `iso4217Currency(for:) returns only built-in currencies,
> so calling `iso4217Currency(for: "BTC")` would return `nil`.

### Showing Off with Emoji

If you're the type of person who enjoys putting clip art in your source code,
here's a trick that'll _really_ impress your teammates:

```swift
typealias 💵 = Money<USD>
typealias 💴 = Money<JPY>
typealias 💶 = Money<EUR>
typealias 💷 = Money<GBP>

let tubeFare: 💷 = 2.40 // "£2.40"
```

## Alternatives to Consider

A type-safe `Money` structure like the one provided by this package
can reduce the likelihood of certain kinds of programming errors.
However, you may find the cost of using this abstraction
to outweigh the benefits it can provide in your code base.

If that's the case,
you might consider implementing your own simple `Money` type
with a nested `Currency` enumeration like this:

```swift
struct Money {
   enum Currency: String {
      case USD, EUR, GBP, CNY // supported currencies here
   }

   var amount: Decimal
   var currency: Currency
}
```

It's ultimately up to you to decide what kind of abstraction
is best for your particular use case.
Whatever you choose,
just make sure to represent monetary amounts using a `Decimal` type
with an explicit currency.

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[build status]: https://github.com/Flight-School/Money/actions?query=workflow%3ACI
[build status badge]: https://github.com/Flight-School/Money/workflows/CI/badge.svg
[currency.swift]: https://github.com/Flight-School/Money/blob/main/Sources/Money/Currency.swift
[iso4217]: https://en.wikipedia.org/wiki/ISO_4217
[iso4217.csv]: https://github.com/Flight-School/Money/blob/main/Resources/iso4217.csv
[gyb]: https://nshipster.com/swift-gyb/
[license]: https://opensource.org/licenses/MIT
[license badge]: https://img.shields.io/cocoapods/l/Money-FlightSchool.svg
[swift version]: https://swift.org/download/
[swift version badge]: https://img.shields.io/badge/swift%20version-4.0+-orange.svg
[cocoapods platforms badge]: https://img.shields.io/cocoapods/p/Money-FlightSchool.svg
[cocoapods]: https://cocoapods.org/pods/Money-FlightSchool
[cocoapods badge]: https://img.shields.io/cocoapods/v/Money-FlightSchool.svg
[carthage]: https://github.com/Carthage/Carthage
[carthage badge]: https://img.shields.io/badge/Carthage-compatible-4BC51D.svg
