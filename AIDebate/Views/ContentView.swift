//
//  ContentView.swift
//  AIDebate
//
//  Created by Jiping Yang on 6/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DebateViewModel()
    @State private var showingSettings = false
    @State private var showingDebate = false

    var body: some View {
        NavigationView {
            ZStack {
                // Keep the background gradient
                LinearGradient(colors: [.white, .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                // 1. Wrap the content in a ScrollView
                // This makes the view scrollable, fixing the keyboard overlap issue.
                ScrollView {
                    VStack(spacing: 30) { // Increased overall vertical spacing
                        // Header
                        VStack(spacing: 10) {
                            Text(" 🤖 AI vs. AI Debate")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Enter a topic and watch AI models debate in real-time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20) // Add some space from the top

                        // Topic Input
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Debate Topic")
                                .font(.headline)
                            
                            // 2. Give the TextField a minimum height and better styling
                            TextField("e.g., 'All public transportation should be free'", text: $viewModel.topic, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...5) // Allow the field to grow
                                .frame(minHeight: 90, alignment: .top) // Set a larger minimum height
                        }

                        // Model Selection
                        HStack(spacing: 15) {
                            VStack(alignment: .leading) {
                                Text("Affirmative Model")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Picker("Affirmative", selection: $viewModel.selectedAffirmativeModel) {
                                    ForEach(0..<viewModel.availableModelNames.count, id: \.self) { index in
                                        Text(viewModel.availableModelNames[index])
                                            .tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Opposition Model")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Picker("Opposition", selection: $viewModel.selectedOppositionModel) {
                                    ForEach(0..<viewModel.availableModelNames.count, id: \.self) { index in
                                        Text(viewModel.availableModelNames[index])
                                            .tag(index)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }

                        // Rounds Selection
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Number of Rounds: \(viewModel.numberOfRounds)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Slider(value: Binding(
                                get: { Double(viewModel.numberOfRounds) },
                                set: { viewModel.numberOfRounds = Int($0) }
                            ), in: 1...5, step: 1)
                        }

                        // Start Button
                        Button(action: {
                            hideKeyboard()
                            showingDebate = true
                        }) {
                            Text("Start Debate")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.topic.isEmpty)

                    }
                    .padding(.horizontal) // Add horizontal padding to all content
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showingDebate) {
            DebateView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
