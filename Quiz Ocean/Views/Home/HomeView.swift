//
//  HomeView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var testStore: TestStore
    
    private var subjects: [Subject] = [
        Subject(firstName: "Number", lastName: "Sense", img: "numbersense"),
        Subject(firstName: "General", lastName: "Mathematics", img: "mathematics"),
        Subject(firstName: "Calculator", lastName: "Application", img: "calculator"),
        Subject(firstName: "General", lastName: "Science", img: "science"),
    ]
    
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
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var showingFinishedSection = true
    @State private var showingStaredSection = true
    @State private var showingScheduledSection = true
    
    var body: some View {
        ScrollView {
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
                    
            Section(header: Text("Subjects")) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(subjects, id: \.self) { subject in
                        NavigationLink(
                            destination: TestsFromSubjectView(subject: subject)
                                .navigationBarTitle(Text(subject.firstName + subject.lastName), displayMode: .large)
                        ) {
                            ZStack(alignment: .center) {
                                Image("blackboard")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 200)
                                
                                HStack {
                                    Image(subject.img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                    
                                    VStack{
                                        Text(subject.firstName)
                                        Text(subject.lastName)
                                    }
                                    .frame(width: 100)
                                }
                                .offset(y: -20)
                            }
                        }
                    }
                }
                    
            }
            
            HStack {
                Toggle(isOn: $showingStaredSection) {
                    Text("Stared")
                }
                
                Toggle(isOn: $showingFinishedSection) {
                    Text("Finished")
                }
                
                Toggle(isOn: $showingScheduledSection) {
                    Text("Scheduled")
                }
            }
            
            if showingStaredSection {
                Section(header: Text("Stared")) {
                    
                }
            }
            if showingFinishedSection {
                Section(header: Text("Finished")) {
                    
                }
            }
            if showingScheduledSection {
                Section(header: Text("Scheduled")) {
                    
                }
            }
        }
//            .navigationTitle(Text("Quiz Ocean"))
//            .listStyle(GroupedListStyle())
//            .environment(\.horizontalSizeClass, .regular)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
//        HomeView()
        HomeView(calendar: Calendar(identifier: .gregorian))
    }
}
