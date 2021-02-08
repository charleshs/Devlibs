import XCTest

final class DateExtensionsTests: XCTestCase {
    private let dateFormatter: DateFormatter = DateFormatter()

    func testTimeZone() {
        let date = Date()
        XCTAssertEqual(date.timeZone, TimeZone.current)
    }

    func testGetYear() {
        let date = self.date(from: "1970/07/01")

        XCTAssertEqual(date?.year, 1970)
    }

    func testSetYear() {
        var date = self.date(from: "1970/07/01")
        date?.year = 1980

        XCTAssertEqual(date, self.date(from: "1980/07/01"))
    }

    func testGetMonth() {
        let date = self.date(from: "1970/07/01")

        XCTAssertEqual(date?.month, 7)
    }

    func testSetMonth() {
        var date = self.date(from: "1970/07/01")
        date?.month = 12

        XCTAssertEqual(date, self.date(from: "1970/12/01"))
    }

    func testGetDay() {
        let date = self.date(from: "1970/07/01")

        XCTAssertEqual(date?.day, 1)
    }

    func testSetDay() {
        var date = self.date(from: "1970/07/01")
        date?.day = 31

        XCTAssertEqual(date, self.date(from: "1970/07/31"))
    }

    func testGetHour() {
        let dateTime = self.dateTime(from: "1970/01/01 20:29:59")

        XCTAssertEqual(dateTime?.hour, 20)
    }

    func testSetHour() {
        var dateTime = self.dateTime(from: "1970/01/01 20:29:59")
        dateTime?.hour = 10

        XCTAssertEqual(dateTime, self.dateTime(from: "1970/01/01 10:29:59"))
    }

    func testGetMinute() {
        let dateTime = self.dateTime(from: "1970/01/01 20:29:59")

        XCTAssertEqual(dateTime?.minute, 29)
    }

    func testSetMinute() {
        var dateTime = self.dateTime(from: "1970/01/01 20:29:59")
        dateTime?.minute = 0

        XCTAssertEqual(dateTime, self.dateTime(from: "1970/01/01 20:00:59"))
    }

    func testGetSecond() {
        let dateTime = self.dateTime(from: "1970/01/01 20:29:59")

        XCTAssertEqual(dateTime?.second, 59)
    }

    func testSetSecond() {
        var dateTime = self.dateTime(from: "1970/01/01 20:29:59")
        dateTime?.second = 0

        XCTAssertEqual(dateTime, self.dateTime(from: "1970/01/01 20:29:00"))
    }

    private func date(from aString: String, format: String = "yyyy/MM/dd") -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: aString)
    }

    private func dateTime(from aString: String, format: String = "yyyy/MM/dd HH:mm:ss") -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: aString)
    }
}
