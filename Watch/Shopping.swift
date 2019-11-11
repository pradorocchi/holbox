import SwiftUI

struct Shopping: View {
    @EnvironmentObject var model: Model
    @State private var name = ""
    
    var body: some View {
        ScrollView {
            Header(name: $name) {
                self.model.project = -1
            }
            Stack()
            Footer(name: $name, title: .init("Delete.title.\(model.mode.rawValue)"), placeholder: .init("Project"), delete: {
                self.model.delete()
            }) {
                self.model.name(self.name)
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                self.name = self.model.name(self.model.project)
        }
    }
}

private struct Stack: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            Groceries()
            Text(.init("Shopping.products"))
                .font(Font.caption
                    .bold())
                .foregroundColor(Color("haze"))
                .opacity(0.6)
                .padding(.top, 20)
            Create()
            Products()
        }
    }
}

private struct Create: View {
    @EnvironmentObject var model: Model
    @State private var create = false
    
    var body: some View {
        Button(action: {
            self.create = true
        }) {
            Image("plusbig")
                .renderingMode(.original)
        }.sheet(isPresented: $create) {
            Stock(emoji: NSLocalizedString("Stock.add.emoji", comment: ""), label: NSLocalizedString("Stock.add.label", comment: ""), show: self.$create)
        }.background(Color.clear)
            .accentColor(.clear)
    }
}

private struct Groceries: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            ForEach(0 ..< model.cards(1), id: \.self) { index in
                NavigationLink(destination:
                    Task(card: .init(list: 1, index: index))
                        .environmentObject(self.model), tag: .init(list: 1, index: index), selection: .init(self.$model.card)) {
                            Grocery(card: .init(list: 1, index: index))
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }
    }
}

private struct Products: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            ForEach(0 ..< model.cards(0), id: \.self) { index in
                NavigationLink(destination:
                    Task(card: .init(list: 1, index: index))
                        .environmentObject(self.model), tag: .init(list: 1, index: index), selection: .init(self.$model.card)) {
                            Product(card: .init(list: 1, index: index))
                }.background(Color.clear)
                    .accentColor(.clear)
            }
        }
    }
}

private struct Grocery: View {
    @EnvironmentObject var model: Model
    let card: Index
    
    var body: some View {
        HStack {
            Image(systemName: card.list == 0 ? "circle.fill" : "checkmark.circle.fill")
                .resizable()
                .foregroundColor(card.list == 0 ? Color("background") : Color("haze"))
                .frame(width: 30, height: 30)
            ForEach(model.marks(card), id: \.1) {
                Item(content: $0.0, mode: $0.1)
            }
            Spacer()
        }
    }
}

private struct Product: View {
    @EnvironmentObject var model: Model
    let card: Index
    
    var body: some View {
        HStack {
            Image(systemName: card.list == 0 ? "circle.fill" : "checkmark.circle.fill")
                .resizable()
                .foregroundColor(card.list == 0 ? Color("background") : Color("haze"))
                .frame(width: 30, height: 30)
            ForEach(model.marks(card), id: \.1) {
                Item(content: $0.0, mode: $0.1)
            }
            Spacer()
        }
    }
}

private struct Stock: View {
    @EnvironmentObject var model: Model
    @State var emoji = ""
    @State var label = ""
    @Binding var show: Bool
    
    var body: some View {
        VStack {
                        TextField(.init("Task"), text: self.$emoji) {
                            self.show = false
        //                    if !self.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        //                        withAnimation(.linear(duration: 0.5)) {
        //                            self.model.addTask(self.emoji)
        //                            self.emoji = ""
        //                        }
        //                    }
                        }.background(Color("background")
                            .cornerRadius(8))
                            .accentColor(.clear)
                        TextField(.init("Task"), text: self.$label) {
                            self.show = false
        //                    if !self.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        //                        withAnimation(.linear(duration: 0.5)) {
        //                            self.model.addTask(self.label)
        //                            self.label = ""
        //                        }
        //                    }
                        }.background(Color("background")
                            .cornerRadius(8))
                            .accentColor(.clear)
                    }
    }
}
