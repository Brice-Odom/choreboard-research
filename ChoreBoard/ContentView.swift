//
//  ContentView.swift
//  ChoreBoard
//
//  Created by Odom, Brice on 10/14/26.
//

import SwiftUI

//chore on list
struct Chore: Identifiable {
    let id = UUID()
    var title: String
    var assignee: String
    var isDone = false
}

struct ContentView: View {
    let roommates = ["alex", "jordan", "sam"]
    
    //value selection through refresh
    @State private var chores: [Chore] = []
    @State private var newTitle = ""
    @State private var newAssignee = "alex"

    var body: some View {
        NavigationStack {
            List {
                Section("create chore...") {
                    TextField("name of chore", text: $newTitle)
                    Picker("assign chore to", selection: $newAssignee) {
                        ForEach(roommates, id: \.self) {Text($0)}
                    }
                    Button("add chore") { addChore() }
                        .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                Section("chores") {
                    ForEach($chores) { $chore in
                        Button {
                            chore.isDone.toggle()
                        } label: {
                            HStack{
                                Image(systemName: chore.isDone ? "checkmark.circle.fill" : "circle")
                                VStack(alignment: .leading) {
                                    Text(chore.title).strikethrough(chore.isDone)
                                    Text(chore.assignee)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("choreboard")
        }
    }
    func addChore() {
        chores.append(Chore(title: newTitle, assignee: newAssignee))
        newTitle = ""
    }
}
