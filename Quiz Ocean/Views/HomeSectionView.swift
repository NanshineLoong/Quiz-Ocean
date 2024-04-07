//
//  MainView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct HomeSectionView: View {
    private var categories: [String] = ["Number Sense", "Mathematics", "Calculator", "Science"]
    
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date() // Cache now

    init(calendar: Calendar) {
        self.calendar = calendar

        self.monthFormatter = DateFormatter()
        self.monthFormatter.dateFormat = "MMMM"
        self.monthFormatter.calendar = calendar

        self.dayFormatter = DateFormatter()
        self.dayFormatter.dateFormat = "d"
        self.dayFormatter.calendar = calendar

        self.weekDayFormatter = DateFormatter()
        self.weekDayFormatter.dateFormat = "EEEEE"
        self.weekDayFormatter.calendar = calendar

        self.fullFormatter = DateFormatter()
        self.fullFormatter.dateFormat = "MMMM dd, yyyy"
        self.fullFormatter.calendar = calendar
    }
    var body: some View {
        NavigationView {
            List {
//                Image("ocean")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 200)
//                        .cornerRadius(20)
//                        .clipped()
                
                CalendarView(
                    calendar: calendar,
                    date: $selectedDate,
                    content: { date in
                        Button(action: { selectedDate = date }) {
                            Text("00")
                                .padding(8)
                                .foregroundColor(.clear)
                                .background(
                                    calendar.isDate(date, inSameDayAs: selectedDate) ? Color.red
                                        : calendar.isDateInToday(date) ? .green
                                        : .blue
                                )
                                .cornerRadius(8)
                                .accessibilityHidden(true)
                                .overlay(
                                    Text(dayFormatter.string(from: date))
                                        .foregroundColor(.white)
                                )
                        }
                    },
                    trailing: { date in
                        Text(dayFormatter.string(from: date))
                            .foregroundColor(.secondary)
                    },
                    header: { date in
                        Text(weekDayFormatter.string(from: date))
                    },
                    title: { date in
                        HStack {
                            Text(monthFormatter.string(from: date))
                                .font(.headline)
                                .padding()
                            Spacer()
                            Button {
                                withAnimation {
                                    guard let newDate = calendar.date(
                                        byAdding: .month,
                                        value: -1,
                                        to: selectedDate
                                    ) else {
                                        return
                                    }

                                    selectedDate = newDate
                                }
                            } label: {
                                Label(
                                    title: { Text("Previous") },
                                    icon: { Image(systemName: "chevron.left") }
                                )
                                .labelStyle(IconOnlyLabelStyle())
                                .padding(.horizontal)
                                .frame(maxHeight: .infinity)
                            }
                            Button {
                                withAnimation {
                                    guard let newDate = calendar.date(
                                        byAdding: .month,
                                        value: 1,
                                        to: selectedDate
                                    ) else {
                                        return
                                    }

                                    selectedDate = newDate
                                }
                            } label: {
                                Label(
                                    title: { Text("Next") },
                                    icon: { Image(systemName: "chevron.right") }
                                )
                                .labelStyle(IconOnlyLabelStyle())
                                .padding(.horizontal)
                                .frame(maxHeight: .infinity)
                            }
                        }
                        .padding(.bottom, 6)
                    }
                )
                .equatable()
                        
                Section(header: Text("Categories")) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(
                            destination: TestFromCategoryView(category: category)
                                .navigationBarTitle(Text(category), displayMode: .large)
                        ) {
                            Text(category)
                        }
                    }
                        
                }
            }
            .navigationTitle(Text("Quiz Ocean"))
//            .listStyle(GroupedListStyle())
//            .environment(\.horizontalSizeClass, .regular)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
//        HomeSectionView()
        HomeSectionView(calendar: Calendar(identifier: .gregorian))
    }
}
