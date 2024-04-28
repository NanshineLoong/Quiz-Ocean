//
//  CalendarView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/4/7.
//

import SwiftUI

struct CalendarView: View {
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter
    
    @State private var selectedDate = Self.now
    private static var now = Date()
    
    @EnvironmentObject var testStore: TestStore
    
    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM YYYY", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "dd MMMM yyyy", calendar: calendar)
    }
    
    var body: some View {
        VStack {
            CalendarViewComponent(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    ZStack {
                        Button(action: { selectedDate = date }) {
                            Text(dayFormatter.string(from: date))
                                .padding(6)
                                // Added to make selection sizes equal on all numbers.
                                .frame(width: 33, height: 33)
                                .foregroundColor(calendar.isDateInToday(date) ? Color.white : .primary)
                                .background(
                                    calendar.isDateInToday(date) ? Color.red
                                    : calendar.isDate(date, inSameDayAs: selectedDate) ? .blue
                                    : .clear
                                )
                                .cornerRadius(7)
                        }
                        
                        if (numberOfEventsInDate(date: date) >= 2) {
                            Circle()
                                .size(CGSize(width: 5, height: 5))
                                .foregroundColor(Color.green)
                                .offset(x: CGFloat(17),
                                        y: CGFloat(33))
                        }
                        
                        if (numberOfEventsInDate(date: date) >= 1) {
                            Circle()
                                .size(CGSize(width: 5, height: 5))
                                .foregroundColor(Color.green)
                                .offset(x: CGFloat(24),
                                        y: CGFloat(33))
                        }
                        
                        if (numberOfEventsInDate(date: date) >= 3) {
                            Circle()
                                .size(CGSize(width: 5, height: 5))
                                .foregroundColor(Color.green)
                                .offset(x: CGFloat(31),
                                        y: CGFloat(33))
                        }
                    }
                },
                trailing: { date in
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(.secondary)
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date)).fontWeight(.bold)
                },
                title: { date in
                    HStack {
                        
                        Button {
                            guard let newDate = calendar.date(
                                byAdding: .month,
                                value: -1,
                                to: selectedDate
                            ) else {
                                return
                            }
                            
                            selectedDate = newDate
                            
                        } label: {
                            Label(
                                title: { Text("Previous") },
                                icon: {
                                    Image(systemName: "chevron.left")
                                        .font(.title2)
                                    
                                }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        Button {
                            selectedDate = Date.now
                        } label: {
                            Text(monthFormatter.string(from: date))
                                .foregroundColor(.blue)
                                .font(.title2)
                                .padding(2)
                        }
                        
                        Spacer()
                        
                        Button {
                            guard let newDate = calendar.date(
                                byAdding: .month,
                                value: 1,
                                to: selectedDate
                            ) else {
                                return
                            }
                            
                            selectedDate = newDate
                            
                        } label: {
                            Label(
                                title: { Text("Next") },
                                icon: {
                                    Image(systemName: "chevron.right")
                                        .font(.title2)
                                    
                                }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                        }
                    }
                }
            )
            .equatable()
        }
    }
    
    func numberOfEventsInDate(date: Date) -> Int {
        var count: Int = 0
        for userTest in testStore.userTests {
            if let scheduledDate = userTest.scheduledDate {
                if calendar.isDate(date, inSameDayAs: scheduledDate) {
                    count += 1
                }
            }
        }
        return count
    }
}

// MARK: - Component

public struct CalendarViewComponent<Day: View, Header: View, Title: View, Trailing: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var testStore: TestStore

    // Injected dependencies
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title
    
    // Constants
    private let daysInWeek = 7
        
    public init(
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder trailing: @escaping (Date) -> Trailing,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title
    }
    
    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        
        VStack {
            
            Section(header: title(month)) { }
            
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                    ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                }
                
                Divider()
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                    ForEach(days, id: \.self) { date in
                        if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                            content(date)
                        } else {
                            trailing(date)
                        }
                    }
                }
            }
            .frame(height: days.count == 42 ? 300 : 270)
            .shadow(color: colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.35), radius: 5)
            
            ForEach(testStore.filterScheduledTests(on: date, for: calendar)) { test in
                NavigationLink {
                    TestView(test: test, userTest: testStore.bindingForUserTest(from: test))
                } label: {
                    ScheduleCardView(test: test)
                }
            }
        }
    }
}


struct ScheduleCardView: View {
    var test: Test

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(test.subject.fullName) // 显示科目的全名
                    .font(.headline)
                Spacer()
                Text(test.level.rawValue) // 显示级别
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("Year: \(test.year)") // 显示年份
            Text("Paper Index: \(test.paperIndex)") // 显示试卷索引
            Text("Questions: \(test.questions.count)") // 显示问题数量
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // 背景颜色
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Conformances

extension CalendarViewComponent: Equatable {
    public static func == (lhs: CalendarViewComponent<Day, Header, Title, Trailing>, rhs: CalendarViewComponent<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarViewComponent {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}

private extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

// MARK: - Previews

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(calendar: Calendar(identifier: .gregorian))
            .environmentObject(TestStore.sample)
    }
}
#endif
