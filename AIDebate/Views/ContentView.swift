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
                  LinearGradient(colors: [.white, .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                      .ignoresSafeArea()

                  VStack(spacing: 20) {
                      // Header
                      VStack(spacing: 10) {
                          Text("🤖 AI vs. AI Debate")
                              .font(.title)
                              .fontWeight(.bold)

                          Text("Enter a topic and watch AI models debate in real-time")
                              .font(.caption)
                              .foregroundColor(.secondary)
                              .multilineTextAlignment(.center)
                      }
                      .padding()
            
                // Topic Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("Debate Topic")
                        .font(.headline)
                    
                    TextField("e.g., 'All public transportation should be free'", text: $viewModel.topic, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3)
                }
                .padding(.horizontal)
                
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
                .padding(.horizontal)
                
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
                .padding(.horizontal)
                
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
                .padding(.horizontal)
                                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                         hideKeyboard()
                         showingDebate = true
                }
                    .disabled(viewModel.topic.isEmpty)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
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
