import Foundation
import Money

let amount = Decimal(12)
let monetaryAmount = Money<USD>(amount)

12 as Money<USD>
12.00 as Money<USD>
"12.00" as Money<USD>

let preciseAmount: Money<USD> = "123.4567"
let roundedAmount: Money<USD> = 123.4567 // rounded to minor unit

preciseAmount.amount // 123.4567
roundedAmount.amount // 123.46

let dollarAmount: Money<USD> = 123.45
let euroAmount: Money<EUR> = 4567.89
let yenAmount: Money<JPY> = 8100
let canadianDollarAmount: Money<CAD> = 234

// dollarAmount == euroAmount // Error: Binary operator '==' cannot be applied

let prices: [Money<USD>] = [2.19, 5.39, 20.99, 2.99, 1.99, 1.99, 0.99]
let subtotal = prices.reduce(0.00, +)
let tax = 0.08 * subtotal
let total = subtotal + tax

let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.locale = Locale(identifier: "fr-FR")
formatter.currencyCode = total.currency.code
formatter.string(for: total.amount)
