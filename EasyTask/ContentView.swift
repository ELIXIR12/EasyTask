//
//  ContentView.swift
//  EasyTask
//
//  Created by Jack Gale on 2/20/25.
//

import SwiftUI
struct ContentView: View {
    @State private var tasks: String = ""
    @State private var processedTasks: [TodoListItem] = []
    @State private var completedTaskCount = 0
    @State private var showGoodJobAlert: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ZStack {
                Text(getDate())
                    .font(.headline)
                    .padding()
                
                if showGoodJobAlert {
                    Text("Well done!")
                        .padding()
                        .padding(.horizontal)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.white)
                        .transition(.opacity)
                }
            }

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(processedTasks) { task in
                        TodoListItemView(completedTaskCount: $completedTaskCount, text: task.text)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }

            Spacer()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomInputView()
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 6)
                .padding(.horizontal)
        }
        .onChange(of: completedTaskCount) {
            handleCompletedTaskCount()
        }
    }

    func bottomInputView() -> some View {
        VStack {
            TextField("", text: $tasks, axis: .vertical)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    HStack {
                        if tasks.isEmpty {
                            Text("Enter your tasks")
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                )
                .textFieldStyle(PlainTextFieldStyle())

            HStack {
                Text("\(completedTaskCount) completed")
                    .padding(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )
                    .foregroundStyle(.gray)
                Spacer()
                Button(action: {
                    processTasks()
                    tasks = ""
                }) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(6)
                        .background(colorScheme == .dark ? Color.white : Color.black)
                        .clipShape(Circle())
                }
                .disabled(tasks.isEmpty)
                .opacity(tasks.isEmpty ? 0 : 1)
            }
        }
        .padding()
    }
    
    func handleCompletedTaskCount() {
        if completedTaskCount >= 3 && !UserDefaults().bool(forKey: "DidShowGoodJobAlert") {
            UserDefaults().set(true, forKey: "DidShowGoodJobAlert")
            showGoodJobAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showGoodJobAlert = false
                }
            }
        }
    }

    func processTasks() {
        let newTasks = tasks
            .split(separator: ",")
            .map { TodoListItem(text: $0.trimmingCharacters(in: .whitespaces)) }
        
        processedTasks = (processedTasks + newTasks).sorted { $0.text < $1.text }
    }

    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

struct TodoListItem: Identifiable {
    var id = UUID()
    var text: String
}

struct TodoListItemView: View {
    @State private var isCompleted: Bool = false
    @Binding var completedTaskCount: Int
    var text: String

    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            isCompleted.toggle()
            completedTaskCount += isCompleted ? 1 : -1
        }
    }
}

#Preview {
    ContentView()
}
