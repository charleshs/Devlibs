import Foundation

extension Date {
    /// Returns the current `Calendar`.
    public var calendar: Calendar {
        return Calendar.current
    }

    /// Returns the current `TimeZone`.
    public var timeZone: TimeZone {
        return calendar.timeZone
    }

    /// Returns the unix timestamp of the date.
    public var unixTimestamp: Double {
        return timeIntervalSince1970
    }

    /// The `year` component of the date.
    public var year: Int {
        get {
            return calendar.component(.year, from: self)
        }
        set {
            guard newValue > 0 else { return }
            let currentYear = calendar.component(.year, from: self)
            let yearsToAdd = newValue - currentYear
            if let date = calendar.date(byAdding: .year, value: yearsToAdd, to: self) {
                self = date
            }
        }
    }

    /// The `month` component of the date.
    public var month: Int {
        get {
            return calendar.component(.month, from: self)
        }
        set {
            setValue(newValue, to: .month, in: .year)
        }
    }

    /// The `day` component of the date.
    public var day: Int {
        get {
            return calendar.component(.day, from: self)
        }
        set {
            setValue(newValue, to: .day, in: .month)
        }
    }

    /// The `hour` component of the date.
    public var hour: Int {
        get {
            return calendar.component(.hour, from: self)
        }
        set {
            setValue(newValue, to: .hour, in: .day)
        }
    }

    /// The `minute` component of the date.
    public var minute: Int {
        get {
            return calendar.component(.minute, from: self)
        }
        set {
            setValue(newValue, to: .minute, in: .hour)
        }
    }

    /// The `second` component of the date.
    public var second: Int {
        get {
            return calendar.component(.second, from: self)
        }
        set {
            setValue(newValue, to: .second, in: .minute)
        }
    }

    private mutating func setValue(_ value: Int, to component: Calendar.Component, in larger: Calendar.Component) {
        guard let allowedRange = calendar.range(of: component, in: larger, for: self),
              allowedRange.contains(value) else { return }

        let current = calendar.component(component, from: self)
        let valueDiff = value - current
        if let date = calendar.date(byAdding: component, value: valueDiff, to: self) {
            self = date
        }
    }

    // Returns the weekday of the date.
    public var weekday: Int {
        return calendar.component(.weekday, from: self)
    }

    /// Returns a boolean indicating whether the date is in future.
    public var isInFuture: Bool {
        return self > Date()
    }

    /// Returns a boolean indicating whether the date is in the past.
    public var isInPast: Bool {
        return self < Date()
    }

    /// Returns a boolean indicating whether the date is in today.
    public var isInToday: Bool {
        return calendar.isDateInToday(self)
    }

    /// Returns a boolean indicating whether the date is in yesterday.
    public var isInYesterday: Bool {
        return calendar.isDateInYesterday(self)
    }

    /// Returns a boolean indicating whether the date is in tomorrow.
    public var isInTomorrow: Bool {
        return calendar.isDateInTomorrow(self)
    }

    /// Returns a boolean indicating whether the date is on weekends.
    public var isInWeekend: Bool {
        return calendar.isDateInWeekend(self)
    }

    /// Returns a string representation of the date formatted by ISO8601.
    @available(iOS 10.0, macOS 10.12, *)
    public var iso8601String: String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: self)
    }

    /// Returns a string representation of the day formatted by a specified format.
    /// - Parameters:
    ///   - format: The date format used by the date formatter to transform a date into a string representation.
    ///   - formatter: A `DateFormatter` object.
    /// - Returns: A string representation of the date formatted by a date formatter.
    public func string(
        withFormat format: String = "dd/MM/yyyy HH:mm",
        using formatter: DateFormatter = DateFormatter()
    ) -> String {
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    /// Returns a string representation of the date components formatted as a given style.
    ///
    ///     Date().dateString(withStyle: .short) -> "2020/11/16"
    ///     Date().dateString(withStyle: .medium) -> "Nov 16, 2020"
    ///     Date().dateString(withStyle: .long) -> "November 16, 2020"
    ///     Date().dateString(withStyle: .full) -> "Monday, November 16, 2020"
    ///
    /// - Parameters:
    ///   - style: DateFormatter style (default is `.medium`).
    ///   - formatter: A `DateFormatter` object.
    /// - Returns: The string representation of the date components.
    public func dateString(
        withStyle style: DateFormatter.Style = .medium,
        using formatter: DateFormatter = DateFormatter()
    ) -> String {
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Returns a string representation of the date and time components formatted as a given style.
    ///
    ///     Date().dateTimeString(withStyle: .short) -> "2020/11/16, 14:36"
    ///     Date().dateTimeString(withStyle: .medium) -> "Nov 16, 2020 at 14:36:39"
    ///     Date().dateTimeString(withStyle: .long) -> "November 16, 2020 at 14:36:39 GMT+8"
    ///     Date().dateTimeString(withStyle: .full) -> "Monday, November 16, 2020 at 14:36:39 Taipei Standard Time"
    ///
    /// - Parameters:
    ///   - dateStyle: DateFormatter style for the date segment (default is `.medium`).
    ///   - timeStyle: DateFormatter style for the time segment (default is `.medium`).
    ///   - formatter: A `DateFormatter` object.
    /// - Returns: The string representation of the date and time components.
    public func dateTimeString(
        dateStyle: DateFormatter.Style = .medium,
        timeStyle: DateFormatter.Style = .medium,
        using formatter: DateFormatter = DateFormatter()
    ) -> String {
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }

    /// Returns a string representation of the time components formatted as a given style.
    ///
    ///     Date().timeString(withStyle: .short) -> "14:34"
    ///     Date().timeString(withStyle: .medium) -> "14:34:24"
    ///     Date().timeString(withStyle: .long) -> "14:34:24 GMT+8"
    ///     Date().timeString(withStyle: .full) -> "14:34:24 Taipei Standard Time"
    ///
    /// - Parameters:
    ///   - style: DateFormatter style (default is `.medium`).
    ///   - formatter: A `DateFormatter` object.
    /// - Returns: The string representation of the time components.
    public func timeString(
        withStyle style: DateFormatter.Style = .medium,
        using formatter: DateFormatter = DateFormatter()
    ) -> String {
        formatter.dateStyle = .none
        formatter.timeStyle = style
        return formatter.string(from: self)
    }
}
