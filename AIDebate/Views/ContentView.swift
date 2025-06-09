//
// ContentView.swift
// AIDebate - Modernized UI
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DebateViewModel()
    @State private var showingSettings = false
    @State private var showingDebate = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 渐变背景 - 延伸到安全区外
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.08),
                        Color.purple.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Header Section
                        HeaderView()
                        
                        // 主内容卡片
                        VStack(spacing: 24) {
                            // Topic Input Section
                            TopicInputSection(topic: $viewModel.topic)
                            
                            // Model Selection Section
                            ModelSelectionSection(
                                affirmativeIndex: $viewModel.selectedAffirmativeModel,
                                oppositionIndex: $viewModel.selectedOppositionModel,
                                modelNames: viewModel.availableModelNames
                            )
                            
                            // Rounds Selection Section
                            RoundsSelectionSection(numberOfRounds: $viewModel.numberOfRounds)
                            
                            // Start Button
                            StartDebateButton(
                                canStart: viewModel.canStart,
                                action: {
                                    hideKeyboard()
                                    showingDebate = true
                                }
                            )
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("开始") {
                        hideKeyboard()
                        showingDebate = true
                    }
                    .disabled(!viewModel.canStart)
                    .foregroundStyle(viewModel.canStart ? .blue : .secondary)
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

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("VS")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.purple)
                    .scaleEffect(x: -1, y: 1)
            }
            
            Text("AI 智辩擂台")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("选择话题，观看 AI 模型实时辩论对决")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Topic Input Section
struct TopicInputSection: View {
    @Binding var topic: String
    @FocusState private var isTopicFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("辩论话题", systemImage: "lightbulb.fill")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            TextField("例如：所有公共交通都应该免费", text: $topic, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(16)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isTopicFocused ? .blue : .clear, lineWidth: 2)
                )
                .focused($isTopicFocused)
                .lineLimit(2...4)
                .font(.body)
        }
    }
}

// MARK: - Model Selection Section
struct ModelSelectionSection: View {
    @Binding var affirmativeIndex: Int
    @Binding var oppositionIndex: Int
    let modelNames: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("模型选择", systemImage: "cpu.fill")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            HStack(spacing: 16) {
                ModelPicker(
                    title: "正方",
                    icon: "hand.thumbsup.fill",
                    iconColor: .blue,
                    selectedIndex: $affirmativeIndex,
                    modelNames: modelNames
                )
                
                ModelPicker(
                    title: "反方",
                    icon: "hand.thumbsdown.fill",
                    iconColor: .red,
                    selectedIndex: $oppositionIndex,
                    modelNames: modelNames
                )
            }
        }
    }
}

// MARK: - Model Picker Component
struct ModelPicker: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var selectedIndex: Int
    let modelNames: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Menu {
                ForEach(0..<modelNames.count, id: \.self) { index in
                    Button(action: {
                        selectedIndex = index
                    }) {
                        HStack {
                            Text(modelNames[index])
                            if selectedIndex == index {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(modelNames[selectedIndex])
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.quaternary, lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Rounds Selection Section
struct RoundsSelectionSection: View {
    @Binding var numberOfRounds: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("辩论轮数", systemImage: "repeat.circle.fill")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(numberOfRounds) 轮")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Slider(
                    value: Binding(
                        get: { Double(numberOfRounds) },
                        set: { numberOfRounds = Int($0) }
                    ),
                    in: 1...5,
                    step: 1
                )
                .tint(.blue)
                
                Text("5")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Start Debate Button
struct StartDebateButton: View {
    let canStart: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "play.circle.fill")
                    .font(.title3)
                Text("开始辩论")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: canStart ? [.blue, .purple] : [.gray, .gray],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: canStart ? .blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .disabled(!canStart)
        .scaleEffect(canStart ? 1.0 : 0.98)
        .opacity(canStart ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: canStart)
    }
}

// MARK: - DebateViewModel Extension
extension DebateViewModel {
    var canStart: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    ContentView()
}
