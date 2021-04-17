import XCTest
import Foundation
@testable import Money

final class MoneyTests: XCTestCase {
    func testMonetaryCalculations() {
        let prices: [Money<USD>] = [2.19, 5.39, 20.99, 2.99, 1.99, 1.99, 0.99]
        let subtotal = prices.reduce(0.00, +)
        let tax = 0.08 * subtotal
        let total = subtotal + tax
        
        XCTAssertEqual(subtotal.amount, Decimal(string: "36.53", locale: nil))
        XCTAssertEqual(tax.amount, Decimal(string: "2.92", locale: nil))
        XCTAssertEqual(total.amount, Decimal(string: "39.45", locale: nil))
    }

    func testMinorUnits() {
        let twoCents = Money<USD>(minorUnits: 2) // $0.02
        XCTAssertEqual(twoCents.amount, Decimal(string: "0.02", locale: nil))

        let ichimonEn = Money<JPY>(minorUnits: 10_000) // ¥10,000
        XCTAssertEqual(ichimonEn.amount, Decimal(string: "10000", locale: nil))
    }

    static var allTests = [
        ("testMonetaryCalculations", testMonetaryCalculations),
        ("testMinorUnits", testMinorUnits),
    ]
}
