//
//  ProfileView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/5/13.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userAttribute: UserAttributeViewModel
    @StateObject var user = UserViewModel()
    @State private var path = NavigationPath()
    var gradient = Gradient(colors: [.yellow, .red, .purple, .orange, .pink, .red])

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 20) {
                // 头像和用户信息
                HStack {
                    Image("user_mock")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(40)
                        .overlay(Circle().stroke(LinearGradient( gradient: gradient, startPoint: .bottomLeading, endPoint: .topTrailing) , style: StrokeStyle(lineWidth: 2.5, lineCap: .round)))
                        .padding([.top, .horizontal], 5)
                    
                    Spacer()
                    
                    VStack {
                        Text(userAttribute.userName).font(.title)
                        Text("ID:LKSDJFLKJLSD157980JF").font(.subheadline).foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Evaluation 区域
                VStack(alignment: .leading, spacing: 15) {
                    Text("Evaluation").font(.headline)
                    HStack(spacing: 20) {
                        Spacer()
                        EvaluationBox(title: "Finished Tests", value: "2")
                        EvaluationBox(title: "Average Score", value: "20")
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                // Progress 区域
                VStack(alignment: .leading, spacing: 15) {
                    Text("Progress").font(.headline)
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(height: 120)
                        .overlay(Text("Score Change").foregroundColor(.gray))
                }
                .padding(.horizontal)
                
                Spacer()

            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        path.append("Settings") // 将设置路径添加到导航路径
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "Settings" {
                    SettingsView() // 跳转到 Settings 页面
                }
            }
        }
    }
}

struct EvaluationBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title).font(.caption).foregroundColor(.gray)
            Text(value).font(.headline)
        }
        .frame(width: 120, height: 60)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}


struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
                .frame(height: 100)
                .overlay(VStack(spacing: 10) {
                    Text("Profile").foregroundColor(.gray)
                    Text("UserName").foregroundColor(.gray)
                })
            
            Button(action: {
                // Logout logic
            }) {
                Text("log out")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
}
