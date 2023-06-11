//
//  ContentView.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import SwiftUI
import CoreData

let APP_GROUP = "group.com.chartinsight.chatWWDC"

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject var webViewModel = WebViewModel()
    
    @ObservedObject var chatViewModel = ChatViewModel()
    
    @State var isSummarized = false
    
    @AppStorage("newURL", store: UserDefaults(suiteName: APP_GROUP)) var urlToSummarize: String = "https://developer.apple.com/videos/play/wwdc2023/10149"
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Text("ChatWWDC")
                    Spacer()
                    Button {
                        chatViewModel.reset()
                        urlToSummarize = ""
                        let userDefaults = UserDefaults(suiteName: APP_GROUP)
                        userDefaults?.set("", forKey: "newURL")
                        isSummarized = false
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                ScrollViewReader { scrollView in
                    ScrollView(.vertical) { // User must scroll off the top to enable programmatic scrolling
                        VStack {
                            if urlToSummarize.count > 0 {
                                WebView(urlString: urlToSummarize, webViewModel: webViewModel)
                                    .frame(height: 300)
                                if isSummarized == false {
                                    Button {
                                        isSummarized = true
                                        // To avoid showing the full transcript in the UI, pass in the url and transcript
                                        chatViewModel.sendMessage(url: urlToSummarize, urlTranscript: webViewModel.transcript)
                                    } label: {
                                        Text("Summarize \(urlToSummarize)")
                                    }.buttonStyle(.borderedProminent)
                                }
                            }
                            
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
        }
    }

    func messageView(message: Message) -> some View {
        HStack {
            let messageText = message.url.isEmpty ? message.content : "Summarize \(message.url)"

            if message.role == .user { Spacer() }
            Text(messageText)
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
