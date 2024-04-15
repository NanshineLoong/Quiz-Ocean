//
//  TestRow.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import SwiftUI

struct TestBoard: View {
    let test: Test
    @Binding var userTest: UserTest?
    @State private var presentDatePicker = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("sticky")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
            testInfo
            
            TagView(userTest: $userTest)
                .onTapGesture {
                    if userTest == nil {
                        userTest = UserTest(testId: test.id)
                    }
                    if userTest?.score == nil {
                        if userTest?.scheduledDate == nil {
                            userTest?.scheduledDate = Date()
                        }
                        self.presentDatePicker = true
                    }
                }
                .padding()
                .sheet(isPresented: $presentDatePicker) {
                    DatePicker("Scheduled Date", selection: Binding(
                        get: { self.userTest?.scheduledDate ?? Date()},
                        set: { self.userTest?.scheduledDate = $0 }
                    ), displayedComponents: [.date])
                }
            
            Image(userTest?.stared ?? false ? "star" : "star_blank")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .onTapGesture {
                    if userTest == nil {
                        userTest = UserTest(testId: test.id)
                    }
                    self.userTest?.stared.toggle()
                }
                .alignmentGuide(.bottom) {$0[.bottom]}
                .padding()

        }
//        .cornerRadius(8)
//        .padding([.leading, .trailing], 16)
//        .padding([.top, .bottom], 8)
//        .shadow(color: .black, radius: 5, x: 0, y: 0)
    }
    
    private var testInfo: some View {
        VStack {
            switch test.level {
            case .middle:
                Image("M")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
            case .high:
                Image("H")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
            }
            
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
}

struct TagView: View {
    @Binding var userTest: UserTest?

    var body: some View {
        ZStack {
            tagBackground
            tagText
        }
        .frame(width: 80, height: 25) // 指定ZStack的尺寸
        .foregroundColor(.white) // 为所有文本设置白色
        .font(.caption) // 设置较小的字体大小
        .cornerRadius(5) // 设置圆角
        .shadow(radius: 2) // 设置阴影
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
        TestBoard(test: test, userTest: .constant(UserTest(testId: test.id)))
    }
}
