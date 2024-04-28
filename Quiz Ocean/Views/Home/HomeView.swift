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
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var showingFinishedSection = true
    @State private var showingStaredSection = true
    @State private var showingScheduledSection = true
    
    @State private var selectedSubject: Subject?
    @State private var showingTestSet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                CalendarView(calendar: Calendar(identifier: .gregorian))
                
                Section(header: Text("Subjects")) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(subjects, id: \.self) { subject in
                            NavigationLink(destination: TestsFromSubjectView(subject: subject)) {
                                SubjectBoard(subject: subject)
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
                        TestsGridView(tests: testStore.filterStaredTests(), columns: columns)
                    }
                }
                if showingFinishedSection {
                    Section(header: Text("Finished")) {
                        TestsGridView(tests: testStore.filterFinishedTests(), columns: columns)
                    }
                }
                if showingScheduledSection {
                    Section(header: Text("Scheduled")) {
                        TestsGridView(tests: testStore.filterScheduledTests(), columns: columns)
                    }
                }
            }
        }
    }
    
    private func SubjectBoard(subject: Subject) -> some View {
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

struct TestsGridView: View {
    var tests: [Test]
    var columns: [GridItem]
    @EnvironmentObject var testStore: TestStore
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(tests, id: \.self) { test in
                withAnimation(.spring()) {
                    TestBoard(test: test, userTest: testStore.bindingForUserTest(from: test))
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
//        HomeView()
        HomeView()
            .environmentObject(TestStore.sample)
    }
}
