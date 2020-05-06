import XCTest
import Foundation
import Money

final class DecodingTests: XCTestCase {
    var decoder = JSONDecoder()

    func testDecodeKeyedContainerWithNumberAmount() throws {
        let json = #"""
            {
                "amount": 27.31,
                "currencyCode": "USD"
            }
        """#.data(using: .utf8)!

        do {
            XCTAssertNoThrow(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            decoder.moneyDecodingOptions = [.requireStringAmount]
            XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            decoder.moneyDecodingOptions = [.roundFloatingPointAmount]

            let actual = try decoder.decode(Money<USD>.self, from: json)
            let expected = Money<USD>(Decimal(string: "27.31")!)

            XCTAssertEqual(actual, expected)
        }
    }

    func testDecodeKeyedContainerWithStringAmount() throws {
        let json = #"""
             {
                 "amount": "27.31",
                 "currencyCode": "USD"
             }
         """#.data(using: .utf8)!

        do {
            XCTAssertNoThrow(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            decoder.moneyDecodingOptions = [.requireStringAmount]

            let actual = try decoder.decode(Money<USD>.self, from: json)
            let expected = Money<USD>(Decimal(string: "27.31")!)

            XCTAssertEqual(actual, expected)
        }
    }

    func testDecodeKeyedContainerWithPreciseStringAmount() throws {
        let json = #"""
             {
                 "amount": "27.309999",
                 "currencyCode": "USD"
             }
         """#.data(using: .utf8)!

        do {
            XCTAssertNoThrow(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            let actual = try decoder.decode(Money<USD>.self, from: json)
            let expected = Money<USD>(Decimal(string: "27.31")!)

            XCTAssertNotEqual(actual, expected)
        }

        do {
            decoder.moneyDecodingOptions = [.roundFloatingPointAmount]

            let actual = try decoder.decode(Money<USD>.self, from: json)
            let expected = Money<USD>(Decimal(string: "27.309999")!)

            XCTAssertEqual(actual, expected)
        }
    }

    func testDecodeUnkeyedContainerWithHeterogeneousRepresentations() throws {
        let json = #"""
            [
                { "currencyCode": "USD", "amount": "100.00" },
                50.00,
                "10"
            ]
        """#.data(using: .utf8)!

        do {
            let actual = try decoder.decode([Money<USD>].self, from: json)
            let expected = [
                Money<USD>(Decimal(string: "100.00")!),
                Money<USD>(Decimal(string: "50.00")!),
                Money<USD>(Decimal(string: "10.00")!),
            ]

            XCTAssertEqual(actual, expected)
        }

        do {
            decoder.moneyDecodingOptions = [.requireExplicitCurrency]
            XCTAssertThrowsError(try decoder.decode([Money<USD>].self, from: json))
        }

        do {
            decoder.moneyDecodingOptions = [.requireStringAmount]
            XCTAssertThrowsError(try decoder.decode([Money<USD>].self, from: json))
        }
    }

    func testDecodeNumberAmount() throws {
        let json = #"""
            [
                27.31
            ]
        """#.data(using: .utf8)!

        do {
            XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            decoder.moneyDecodingOptions = [.roundFloatingPointAmount]

            let actual = try decoder.decode([Money<USD>].self, from: json)
            let expected = [Money<USD>(Decimal(string: "27.31")!)]

            XCTAssertEqual(actual, expected)
        }
    }

    func testDecodeNegativeNumberAmount() throws {
        let json = #"""
              [
                  -27.31
              ]
          """#.data(using: .utf8)!

        do {
            XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            decoder.moneyDecodingOptions = [.roundFloatingPointAmount]

            let actual = try decoder.decode([Money<USD>].self, from: json)
            let expected = [Money<USD>(Decimal(string: "-27.31")!)]

            XCTAssertEqual(actual, expected)
        }
    }

    func testDecodeIntegerNumberAmount() throws {
        let json = #"""
              [
                  27
              ]
          """#.data(using: .utf8)!

        do {
            XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
        }
        do {
            let actual = try decoder.decode([Money<USD>].self, from: json)
            let expected = [Money<USD>(Decimal(string: "27")!)]

            XCTAssertEqual(actual, expected)
        }

        do {
            decoder.moneyDecodingOptions = [.requireExplicitCurrency]
            XCTAssertThrowsError(try decoder.decode([Money<USD>].self, from: json))
        }


    }

    func testDecodeZeroNumberAmount() throws {
        let json = #"""
              [
                  0
              ]
          """#.data(using: .utf8)!

        do {
            XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            let actual = try decoder.decode([Money<USD>].self, from: json)
            let expected = [Money<USD>(Decimal(string: "0")!)]

            XCTAssertEqual(actual, expected)
        }
    }

    func testDecodeExponentNumberAmount() throws {
        let json = #"""
              [
                  2.731e1
              ]
          """#.data(using: .utf8)!

        do {
            XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
        }

        do {
            decoder.moneyDecodingOptions = [.roundFloatingPointAmount]

            let actual = try decoder.decode([Money<USD>].self, from: json)
            let expected = [Money<USD>(Decimal(string: "27.31")!)]

            XCTAssertEqual(actual, expected)
        }
    }

    func testDecodeKeyedContainerWithMismatchedCurrency() throws {
        let json = #"""
            {
                "amount": 27.31,
                "currencyCode": "EUR"
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    func testDecodeKeyedContainerWithMissingCurrency() throws {
        let json = #"""
            {
                "amount": 27.31,
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    func testDecodeKeyedContainerWithInvalidStringAmount() throws {
        let json = #"""
               {
                   "amount": "One Million Dollars"
                   "currencyCode": "USD"
               }
           """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    func testDecodeKeyedContainerWithMissingAmount() throws {
        let json = #"""
            {
                "currencyCode": "USD"
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    func testDecodeEmptyKeyedContainer() throws {
        let json = #"""
            {
            }
        """#.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Money<USD>.self, from: json))
    }

    static var allTests = [
        ("testDecodeKeyedContainerWithNumberAmount", testDecodeKeyedContainerWithNumberAmount),
        ("testDecodeKeyedContainerWithStringAmount", testDecodeKeyedContainerWithStringAmount),
        ("testDecodeKeyedContainerWithPreciseStringAmount", testDecodeKeyedContainerWithPreciseStringAmount),
        ("testDecodeUnkeyedContainerWithHeterogeneousRepresentations", testDecodeUnkeyedContainerWithHeterogeneousRepresentations),
        ("testDecodeNumberAmount", testDecodeNumberAmount),
        ("testDecodeNegativeNumberAmount", testDecodeNegativeNumberAmount),
        ("testDecodeIntegerNumberAmount", testDecodeIntegerNumberAmount),
        ("testDecodeZeroNumberAmount", testDecodeZeroNumberAmount),
        ("testDecodeExponentNumberAmount", testDecodeExponentNumberAmount),
        ("testDecodeKeyedContainerWithMismatchedCurrency", testDecodeKeyedContainerWithMismatchedCurrency),
        ("testDecodeKeyedContainerWithMissingCurrency", testDecodeKeyedContainerWithMissingCurrency),
        ("testDecodeKeyedContainerWithInvalidStringAmount", testDecodeKeyedContainerWithInvalidStringAmount),
        ("testDecodeKeyedContainerWithMissingAmount", testDecodeKeyedContainerWithMissingAmount),
        ("testDecodeEmptyKeyedContainer", testDecodeEmptyKeyedContainer),
    ]
}
