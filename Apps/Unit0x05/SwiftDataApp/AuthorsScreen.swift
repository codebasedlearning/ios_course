// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import SwiftData
import CblUI

struct AuthorsScreen: View {
    
    var body: some View {
        CblScreen(title: "Authors", image: "lego_background") {
            VStack {
                AuthorsView()
             }
        }
    }
}

/*
 @Query watch the Book table in SwiftData. Anytime a matching record is added,
 deleted, or updated — automatically reflect that change in the view.

 It’s like @FetchRequest in Core Data, but:
 - Type-safe (no stringly-typed predicates)
 - Works with #Predicate macros
 - Supports sorting via Swift-native KeyPaths.
 
 Declares a live-binding read-only collection from SwiftData.
 - Automatically re-evaluates when the database changes.
 - Injects SwiftUI reactivity: @Query is re-fetched when needed.
 - @Query takes a FetchDescriptor<T> (predicate, sort, limit) and gives
    back a live, auto-updating array of results. The type parameter T
    tells it which @Model to fetch.
 - @Query only works inside a View that has a container installed up
    the hierarchy via .modelContainer(...). Try using @Query in a plain
    class or an @Observable view model and it won't work — there's
    no environment to pull from.
 
 can also
 
 @Query(sort: [
     SortDescriptor(\Author.name),
     SortDescriptor(\Author.books.count, order: .reverse)
 ]) var authors: [Author]
 
 or
 
 @Query(
     filter: #Predicate<Author> { $0.books.count > 0 },
     sort: [SortDescriptor(\Author.name)]
 ) var activeAuthors: [Author]
 
 */

struct AuthorsView: View {
    // here is the .modelContext from the .modelContainer
    @Environment(\.modelContext) private var modelContext

    @State private var searchText = ""
    
    @Query(sort: \Author.name) private var authors: [Author]
    // short for: @Query(sort: [SortDescriptor(\Author.name)]) private var authors: [Author]
    
    var filteredAuthors: [Author] {
        if searchText.isEmpty {
            return authors
        } else {
            return authors.filter { $0.name.localizedStandardContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredAuthors) { author in
                    NavigationLink(destination: AuthorDetailView(author: author)) {
                        //let id = author.id
                        Text("\(author.name)")
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Authors")
            .toolbar {
                Button("Add Author") {
                    let author = Author(name: "New Author \(Int.random(in: 1...100))")
                    modelContext.insert(author)
                }
            }
        }
    }
}

struct AuthorDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var author: Author

    @State private var newBookTitle = ""
    @State private var sortByTitle = false

    var sortedBooks: [Book] {
        sortByTitle ?
            author.books.sorted { $0.title < $1.title } :
            author.books.sorted { $0.timestamp < $1.timestamp }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Sort")) {
                Toggle("Sort by title", isOn: $sortByTitle)
            }

            Section(header: Text("Books by \(author.name)")) {
                ForEach(sortedBooks) { book in          // author.books
                    VStack(alignment: .leading) {
                        Text(book.title)
                        Text(book.timestamp, style: .date)
                            .font(.caption)
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            
            Section(header: Text("Author")) {
                TextField("Name", text: $author.name)
            }

            Section(header: Text("Add New Book")) {
                TextField("Book Title", text: $newBookTitle)
                Button("Add Book") {
                    let book = Book(title: newBookTitle, author: author)
                    modelContext.insert(book)
                    newBookTitle = ""
                }
                .disabled(newBookTitle.isEmpty)
            }
        }
        .navigationTitle(author.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteBooks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(author.books[index])
        }
    }
}
