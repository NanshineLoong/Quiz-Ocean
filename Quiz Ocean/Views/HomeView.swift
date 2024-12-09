//
//  HomeView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var wrongQStore: WrongQuestionsStore
    
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
//            Button(action: {
//                testStore.uploadLocalTests()
//            }) {
//                Text("Upload Local Tests")
//            }
            ZStack {
                ScrollView {
                    HeaderView()
                    
                    // Tasks
                    TaskListView(path: $path)
                    
                    // Choose a Test
                    ChooseTestView(path: $path)
                }
            }
            .navigationDestination(for: TestViewModel.self) { test in
                FullTestView(
                    test: test,
                    path: $path
                )
            }
            .navigationDestination(for: StaticTest.self) { staticTest in
                FullTestView(
                    test: TestViewModel(questionIDs: staticTest.questionIDs, testId: staticTest.id, testTitle: staticTest.title),
                    path: $path
                )
            }
            .ignoresSafeArea(.all, edges: .top)
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject var userAttribute: UserAttributeViewModel
    @State private var greeting: String = ""
    @State private var imageName: String = ""
    @State private var backgroundGradient: LinearGradient = LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hi, \(userAttribute.userName)")
                    .font(.system(size:24, weight: .semibold, design: .rounded))
                Text(greeting)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
            Spacer()
            Image(imageName)
                .resizable()
                .frame(width: 100, height: 100)
                .scaledToFit()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 200)
        .background(backgroundGradient)
        .onAppear {
            updateGreeting()
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            greeting = "Good morning!"
            imageName = "morning"
            backgroundGradient = LinearGradient(
                colors: [Color.orange, Color.yellow.opacity(0.6), Color.white],
                startPoint: .top, endPoint: .bottom
            )
        case 12..<18:
            greeting = "Good afternoon!"
            imageName = "afternoon"
            backgroundGradient = LinearGradient(
                colors: [Color.cyan, Color.white],
                startPoint: .top, endPoint: .bottom
            )
        default:
            greeting = "Good evening!"
            imageName = "evening"
            backgroundGradient = LinearGradient(
                colors: [Color.purple, Color.indigo.opacity(0.6), Color.white],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}


#Preview {
    let testStore = TestStore()
    let taskStore = TaskStore()
    let wrongQStore = WrongQuestionsStore()
    let userAttribute = UserAttributeViewModel()
    
    HomeView()
        .onAppear {
            testStore.setup()
            taskStore.setup()
            wrongQStore.setup()
            userAttribute.setup()
        }
        .environmentObject(taskStore)
        .environmentObject(wrongQStore)
        .environmentObject(testStore)
        .environmentObject(userAttribute)
}

#Preview {
    HeaderView()
}
