import SwiftUI
import Contacts

struct ContactsView: View {
    @ObservedObject var viewModel: CleanerViewModel
    @State private var selectedContacts = Set<String>()
    @State private var isAllSelected = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            
            if groupedContacts.isEmpty {
                Spacer()
                Text("No duplicate phones yet")
                    .foregroundColor(.cFFFFFF.opacity(0.4))
                    .padding()
                Spacer()
            } else {
                ZStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            Spacer()
                                .frame(height: 40)
                            ForEach(groupedContacts, id: \.title) { group in
                                if !group.contacts.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text(group.title)
                                                .font(.custom("Inter-Bold", size: 16))
                                                .foregroundColor(.cFFFFFF)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                let allSelected = group.contacts.allSatisfy { selectedContacts.contains($0.identifier) }
                                                if allSelected {
                                                    for contact in group.contacts {
                                                        selectedContacts.remove(contact.identifier)
                                                    }
                                                } else {
                                                    for contact in group.contacts {
                                                        selectedContacts.insert(contact.identifier)
                                                    }
                                                }
                                            }) {
                                                let allSelected = group.contacts.allSatisfy { selectedContacts.contains($0.identifier) }
                                                Image(allSelected ? "selectAll" : "selectAllEmpty")
                                            }
                                        }
                                        
                                        VStack(spacing: 12) {
                                            ForEach(group.contacts) { contact in
                                                HStack(spacing: 8) {
                                                    contactImage(for: contact)
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(contact.name)
                                                            .font(.custom("Inter-SemiBold", size: 14))
                                                            .foregroundColor(.cFFFFFF)
                                                        Text(contact.phoneNumber)
                                                            .font(.custom("Inter-SemiBold", size: 12))
                                                            .foregroundColor(.cFFFFFF)
                                                    }
                                                    Spacer()
                                                    Button(action: {
                                                        toggleSelection(for: contact.identifier)
                                                    }) {
                                                        Image(selectedContacts.contains(contact.identifier) ? "checkbox" : "checkboxEmpty")
                                                            .resizable()
                                                            .frame(width: 24, height: 24)
                                                    }
                                                }
                                                .padding(.vertical , 12)
                                                .padding(.horizontal , 16)
                                                .background(Color.c310057.opacity(0.4))
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    VStack {
                        Spacer()
                        Button(action: deleteSelectedContacts) {
                            ZStack {
                                Image("Clean")
                                Text("Clean")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundStyle(.cFFFFFF)
                                    .opacity(selectedContacts.isEmpty ? 0.5 : 1)
                            }
                        }
                        .padding()
                        .disabled(selectedContacts.isEmpty)
                    }
                }
            }
        }
        .onAppear {
            viewModel.requestAccessToContacts()
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Helper Methods
    private func toggleSelection(for identifier: String) {
        if selectedContacts.contains(identifier) {
            selectedContacts.remove(identifier)
        } else {
            selectedContacts.insert(identifier)
        }
    }
    
    private func deleteSelectedContacts() {
        for identifier in selectedContacts {
            viewModel.deleteContact(identifier: identifier)
        }
        selectedContacts.removeAll()
    }
    
    private var groupedContacts: [(title: String, contacts: [Contact])] {
        var groups: [(String, [Contact])] = []
        
        if !viewModel.similarContacts.isEmpty {
            let flattened = viewModel.similarContacts.flatMap { $0 }
            groups.append(("Duplicate Contacts", flattened))
        }
        
        if !viewModel.emptyContacts.isEmpty {
            groups.append(("Empty Contacts", viewModel.emptyContacts))
        }
        
        return groups
    }
    
    @ViewBuilder
    private func contactImage(for contact: Contact) -> some View {
        if let data = contact.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ContactsView(viewModel: {
        let viewModel = CleanerViewModel()
        
        viewModel.similarContacts = [
            [
                Contact(name: "1", phoneNumber: "John Doe", identifier: "+123456789", imageData: nil),
                Contact(name: "2", phoneNumber: "John D.", identifier: "+123456789", imageData: nil)
            ],
            [
                Contact(name: "3", phoneNumber: "Jane Smith", identifier: "+987654321", imageData: nil),
                Contact(name: "4", phoneNumber: "J. Smith", identifier: "+987654321", imageData: nil)
            ]
        ]
        
        
        viewModel.emptyContacts = [
            Contact(name: "5", phoneNumber: "", identifier: "", imageData: nil),
            Contact(name: "6", phoneNumber: "No Number", identifier: "", imageData: nil),
            Contact(name: "7", phoneNumber: "", identifier: "+000000000", imageData: nil),
            Contact(name: "8", phoneNumber: "Empty", identifier: "", imageData: nil),
            Contact(name: "9", phoneNumber: "", identifier: "", imageData: nil),
            Contact(name: "10", phoneNumber: "Test", identifier: "", imageData: nil)
        ]
        
        return viewModel
    }())
    .preferredColorScheme(.dark)
}

