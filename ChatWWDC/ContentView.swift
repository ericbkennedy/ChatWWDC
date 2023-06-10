//
//  ContentView.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var chatViewModel = ChatViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView(.vertical) { // User must scroll off the top to enable programmatic scrolling
                        VStack {
                            ForEach(chatViewModel.messages.filter({$0.role != .system}),
                                    id: \.id)
                            { message in
                                messageView(message: message)
                            }
                            // For CoreData support, use .onDelete(perform: deleteItems)
                        }.id("VStackInScrollView")
                    }.onChange(of: chatViewModel.totalResponseCount) { _ in
                        withAnimation {
                            scrollView.scrollTo("VStackInScrollView", anchor: .bottom)
                        }
                    }
                }
                HStack {
                    TextField("Enter a message",
                              text: $chatViewModel.currentInput,
                              axis: .vertical )
                    .lineLimit(2...10)
                    .onSubmit {
                        chatViewModel.sendMessage() // enables submit on return key press
                    }
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    Button {
                        chatViewModel.sendMessage()
                    } label: {
                        Text("Send")
                    }
                }
            }
            .padding()
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
        }
    }

    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer() }
            Text(message.content)
                .padding()
                .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(15.0)
            if message.role == .assistant { Spacer() }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
