import XCTest
import Foundation
@testable import Money

final class EncodingTests: XCTestCase {
    let money = Money<USD>(Decimal(string: "27.31")!)

    var encoder = JSONEncoder()

    override func setUp() {
        if #available(OSX 10.13, *) {
            encoder.outputFormatting = .sortedKeys
        }
    }

    func testEncodeKeyedContainerWithNumberAmount() throws {
        let data = try encoder.encode(money)
        let actual = String(data: data, encoding: .utf8)

        let expected = #"{"amount":27.31,"currencyCode":"USD"}"#

        XCTAssertEqual(actual, expected)
    }

    func testEncodeKeyedContainerWithStringAmount() throws {
        encoder.moneyEncodingOptions = [.encodeAmountAsString]

        let data = try encoder.encode(money)
        let actual = String(data: data, encoding: .utf8)

        let expected = #"{"amount":"27.31","currencyCode":"USD"}"#

        XCTAssertEqual(actual, expected)
    }

    func testEncodeKeyedContainerWithCustomKeys() throws {
        struct AnyKey: CodingKey {
            var stringValue: String
            var intValue: Int?

            init(stringValue: String) {
                self.stringValue = stringValue
                self.intValue = nil
            }

            init(intValue: Int) {
                self.stringValue = String(intValue)
                self.intValue = intValue
            }
        }

        encoder.keyEncodingStrategy = .custom({ keys in
            switch keys.last {
            case MoneyCodingKeys.amount?:
                return AnyKey(stringValue: "value")
            case MoneyCodingKeys.currencyCode?:
                return AnyKey(stringValue: "currency")
            default:
                return keys.last!
            }
        })

        let data = try encoder.encode(money)
        let actual = String(data: data, encoding: .utf8)

        let expected = #"{"currency":"USD","value":27.31}"#

        XCTAssertEqual(actual, expected)
    }

    func testEncodeSingleValueContainerWithNumberAmount() throws {
        encoder.moneyEncodingOptions = [.omitCurrency]

        let data = try encoder.encode([money])
        let actual = String(data: data, encoding: .utf8)

        let expected = #"[27.31]"#

        XCTAssertEqual(actual, expected)
    }

    func testEncodeSingleValueContainerWithStringAmount() throws {
        encoder.moneyEncodingOptions = [.omitCurrency, .encodeAmountAsString]

        let data = try encoder.encode([money])
        let actual = String(data: data, encoding: .utf8)

        let expected = #"["27.31"]"#

        XCTAssertEqual(actual, expected)
    }

    static var allTests = [
        ("testEncodeKeyedContainerWithNumberAmount", testEncodeKeyedContainerWithNumberAmount),
        ("testEncodeKeyedContainerWithStringAmount", testEncodeKeyedContainerWithStringAmount),
        ("testEncodeSingleValueContainerWithNumberAmount", testEncodeSingleValueContainerWithNumberAmount),
        ("testEncodeSingleValueContainerWithStringAmount", testEncodeSingleValueContainerWithStringAmount),
    ]
}
