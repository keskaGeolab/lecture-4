import SwiftUI

struct ContentView: View {
    @State private var products = [
        Product(name: "პური", emoji: "🍞"),
        Product(name: "რძე", emoji: "🥛"),
        Product(name: "ვაშლი", emoji: "🍎"),
        Product(name: "ყველი", emoji: "🧀"),
        Product(name: "კვერცხი", emoji: "🥚")
    ]
    @State private var newProduct = ""
    @State private var searchText = ""

    private var filteredProducts: [Product] {
        searchText.isEmpty ? products : products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var toBuy: [Product] { filteredProducts.filter { !$0.isBought } }
    private var bought: [Product] { filteredProducts.filter { $0.isBought } }

    var body: some View {
        NavigationStack {
            Group {
                if filteredProducts.isEmpty {
                    ContentUnavailableView(searchText.isEmpty ? "სია ცარიელია" : "ვერაფერი მოიძებნა", systemImage: searchText.isEmpty ? "cart" : "magnifyingglass", description: Text(searchText.isEmpty ? "დაამატე ახალი პროდუქტი" : "სცადე სხვა საძიებო სიტყვა"))
                } else {
                    List {
                        Section("საყიდელი") {
                            ForEach(toBuy) { product in productRow(product) }
                                .onDelete { deleteProducts(at: $0, from: toBuy) }
                                .onMove { moveProducts(from: $0, to: $1, in: toBuy) }
                        }
                        Section("ნაყიდი") {
                            ForEach(bought) { product in productRow(product) }
                                .onDelete { deleteProducts(at: $0, from: bought) }
                                .onMove { moveProducts(from: $0, to: $1, in: bought) }
                        }
                    }
                }
            }
            .navigationTitle("საყიდლები")
            .searchable(text: $searchText, prompt: "პროდუქტის ძებნა")
            .toolbar { EditButton() }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    TextField("ახალი პროდუქტი", text: $newProduct)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(addProduct)
                    Button("დამატება", action: addProduct)
                        .buttonStyle(.borderedProminent)
                        .disabled(newProduct.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.bar)
            }
        }
    }

    private func productRow(_ product: Product) -> some View {
        HStack {
            Text(product.emoji).font(.title2)
            Text(product.name)
            Spacer()
            Button { toggleBought(product) } label: {
                Image(systemName: product.isBought ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(product.isBought ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private func addProduct() {
        let name = newProduct.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        products.append(Product(name: name, emoji: "🛒"))
        newProduct = ""
    }

    private func toggleBought(_ product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return }
        products[index].isBought.toggle()
    }

    private func deleteProducts(at offsets: IndexSet, from list: [Product]) {
        let ids = offsets.map { list[$0].id }
        products.removeAll { ids.contains($0.id) }
    }

    private func moveProducts(from source: IndexSet, to destination: Int, in list: [Product]) {
        var reordered = list
        reordered.move(fromOffsets: source, toOffset: destination)
        let ids = reordered.map(\.id)
        let moved = reordered.compactMap { item in products.first { $0.id == item.id } }
        let remaining = products.filter { !ids.contains($0.id) }
        products = moved + remaining
    }
}
