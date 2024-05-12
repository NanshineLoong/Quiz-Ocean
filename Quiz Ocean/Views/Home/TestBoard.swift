//
//  TestRow.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import SwiftUI

struct ExampleView: View {
    var body: some View {
        Image("sticky")
    }
}

struct TestBoard: View {
    let test: Test
    @Binding var userTest: UserTest?
    @State private var presentDatePicker = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: TestView(test: test, userTest: $userTest)) {
                ZStack {
                    Image("sticky")

                    testInfo
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack {
                TagView(userTest: $userTest)
                    .onTapGesture {
                        if userTest == nil {
                            userTest = UserTest(userid: UUID(), testid: test.id)
                        }
                        if userTest?.score == nil {
                            if userTest?.scheduledDate == nil {
                                userTest?.scheduledDate = Date()
                            }
                            self.presentDatePicker = true
                        }
                    }
                    .padding(.leading, -80)
                    .padding(.bottom, -100)
                
                Image(userTest?.stared ?? false ? "star" : "star_blank")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .onTapGesture {
                        if userTest == nil {
                            userTest = UserTest(userid: UUID(), testid: test.id)
                        }
                        self.userTest?.stared.toggle()
                    }
                    .padding(.trailing, -100)
                    .padding(.bottom, -1000)
            }
            if self.presentDatePicker {
                DatePickerOverlay(userTest: $userTest, presentDatePicker: $presentDatePicker)
            }
        }
    }
    
    private var testInfo: some View {
        VStack {
            ImageForLevel(test.level)
            Text(test.year)
                .font(.headline)
                .padding([.leading, .trailing])
            
            Text(test.paperIndex)
                .font(.subheadline)
                .padding([.leading, .trailing])
            
            Image(test.subject.img)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
        }
    }
    
    private func ImageForLevel(_ level: Test.Level) -> some View {
        Image(level == .middle ? "M" : "H")
            .resizable()
            .scaledToFit()
            .frame(width: 25)
    }
}

struct DatePickerOverlay: View {
    @Binding var userTest: UserTest?
    @Binding var presentDatePicker: Bool
    
    var body: some View {
        VStack {
            DatePicker("Scheduled Date", selection: Binding(
                get: { self.userTest?.scheduledDate ?? Date() },
                set: { self.userTest?.scheduledDate = $0 }
            ), displayedComponents: [.date])
            .datePickerStyle(CompactDatePickerStyle())
            .frame(maxWidth: .infinity)
            Button("Done") {
                self.presentDatePicker = false
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(5.0)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
}

struct TagView: View {
    @Binding var userTest: UserTest?

    var body: some View {
        ZStack(alignment: .center) {
            tagBackground
            tagText
        }
        .frame(width: 60, height: 35)
        .foregroundColor(.white)
    }

    private var tagBackground: some View {
        Image(userTest != nil && userTest!.score != nil ? "tag_green" : "tag_red")
            .resizable()
            .aspectRatio(contentMode: .fill)
    }

    private var tagText: some View {
        Text(displayText)
    }

    private var displayText: String {
        if let score = userTest?.score {
            return "\(score)"
        } else if let scheduledDate = userTest?.scheduledDate {
            return scheduledDate.formatted()
        } else {
            return "unfin."
        }
    }
}

struct TestBoard_Previews: PreviewProvider {
    static var test = Test(subject: Subject(firstName: "Number", lastName: "Sense", img: "numbersense"), level: .middle, year: "2024", paperIndex: "#13", questions: [])
    static var previews: some View {
        TestBoard(test: test, userTest: .constant(UserTest(userid: UUID(), testid: test.id)))
//        ExampleView()
    }

}
