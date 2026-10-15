//
//  ContentView.swift
//  ChoreBoard
//
//  Created by Odom, Brice on 10/14/26.
//

import SwiftUI
import Supabase

//chore on list
struct Chore: Codable, Identifiable {
    let id: Int
    var title: String
    var assignee: String
    var isDone: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, assignee
        case isDone = "is_done"
    }
}

struct NewChore: Encodable {
    let title: String
    let assignee: String
}

struct ContentView: View {
    let roommates = ["alex", "jordan", "sam"]
    
    //value selection through refresh
    @State private var chores: [Chore] = []
    @State private var newTitle = ""
    @State private var newAssignee = "alex"
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("create chore...") {
                    TextField("name of chore", text: $newTitle)
                    Picker("assign chore to", selection: $newAssignee) {
                        ForEach(roommates, id: \.self) {Text($0)}
                    }
                    Button("add chore") {
                        Task { await addChore() }
                    }
                        .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red) }
                }
                
                Section("chores") {
                    ForEach(chores) { chore in
                        Button {
                            Task { await toggle(chore) }
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
            .task { await loadChores() }
            .refreshable { await loadChores() }
        }
    }
    func loadChores() async {
        do {
            chores = try await supabase
                .from("chores")
                .select()
                .order("id")
                .execute()
                .value
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addChore() async {
        do {
            try await supabase
                .from("chores")
                .insert(NewChore(title: newTitle, assignee: newAssignee))
                .execute()
            newTitle = ""
            await loadChores()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggle(_ chore: Chore) async {
        do {
            try await supabase
                .from("chores")
                .update(["is_done": !chore.isDone])
                .eq("id", value: chore.id)
                .execute()
            await loadChores()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
