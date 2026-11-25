import SwiftUI
import UIKit

struct ContentView: View {
    @State private var appState = AppState()
    @State private var auth = AuthStore()
    private let theme = CLTheme.light()

    var body: some View {
        Group {
#if targetEnvironment(simulator)
            // Simulator always boots into the main shell with a local preview profile.
            MainApp(state: appState, auth: auth, theme: theme)
#else
            if auth.isRestoring {
                ZStack {
                    theme.bg.ignoresSafeArea()
                    ProgressView()
                }
            } else if !auth.isSignedIn {
                SignInView(auth: auth, theme: theme)
            } else if auth.needsWebOnboarding {
                OnboardingFlowView(auth: auth, theme: theme)
            } else {
                MainApp(state: appState, auth: auth, theme: theme)
            }
#endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .preferredColorScheme(.light)
        .onOpenURL { url in
            Task { await auth.handleIncomingURL(url) }
        }
        .onChange(of: auth.sessionToken) { _, token in
            appState.syncSession(token: token, user: auth.user)
            if token == AuthStore.simulatorPreviewToken {
                appState.loadSimulatorPreviewCatalog()
            } else if token != nil {
                Task {
                    await appState.refreshOpportunities()
                    await appState.refreshApplied()
                }
            } else {
                appState.logOut()
            }
        }
        .onChange(of: auth.user?.id) { _, _ in
            appState.syncSession(token: auth.sessionToken, user: auth.user)
        }
        .onAppear {
#if targetEnvironment(simulator)
            if !auth.isSimulatorPreview {
                auth.enterSimulatorPreview()
            }
            appState.syncSession(token: auth.sessionToken, user: auth.user)
            appState.loadSimulatorPreviewCatalog()
#endif
        }
        .task(id: auth.isSignedIn) {
            guard auth.isSignedIn else { return }
            appState.onSessionExpired = {
                auth.signOut()
                appState.logOut()
            }
            appState.syncSession(token: auth.sessionToken, user: auth.user)
            if auth.isSimulatorPreview {
                appState.loadSimulatorPreviewCatalog()
                return
            }
            await appState.refreshProfile()
            await appState.refreshOpportunities()
            await appState.refreshApplied()
        }
    }
}

// MARK: - Main App
struct MainApp: View {
    @Bindable var state: AppState
    @Bindable var auth: AuthStore
    let theme: CLTheme

    var body: some View {
        NavigationStack(path: $state.navigationPath) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.bg)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    CLTabBar(
                        tab: Binding(
                            get: { state.currentTab },
                            set: { state.setTab($0) }
                        ),
                        theme: theme,
                        onTab: { state.setTab($0) }
                    )
                }
                .clInteractivePopGesture()
                .navigationDestination(for: AppRoute.self) { route in
                    routeScreen(route)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                        .toolbarBackground(.hidden, for: .navigationBar)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clInteractivePopGesture()
                        .overlay(alignment: .leading) {
                            Color.clear
                                .frame(width: 20)
                                .frame(maxHeight: .infinity)
                                .contentShape(Rectangle())
                                .highPriorityGesture(
                                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                        .onEnded { value in
                                            let swipedRight = value.translation.width > 70
                                            let mostlyHorizontal =
                                                abs(value.translation.width) > abs(value.translation.height) * 1.2
                                            if swipedRight && mostlyHorizontal {
                                                state.pop()
                                            }
                                        }
                                )
                        }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .overlay(alignment: .top) {
            if !state.toastMessage.isEmpty {
                CLToast(message: state.toastMessage, icon: state.toastIcon, theme: theme)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.22), value: state.toastMessage.isEmpty)
        .onAppear { Self.removeOrphanStatusBarStrip() }
        .onChange(of: state.navigationPath.count) { _, _ in
            // Detail used to paint a key-window strip that could stick after pop.
            if state.navigationPath.isEmpty {
                Self.removeOrphanStatusBarStrip()
            }
        }
    }

    /// Clears a leaked status-bar overlay from an earlier DropDetail window chrome.
    private static let orphanStatusStripTag = 9_314_201
    private static func removeOrphanStatusBarStrip() {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes {
            for window in scene.windows {
                window.viewWithTag(orphanStatusStripTag)?.removeFromSuperview()
            }
        }
    }

    /// Keep all tab roots alive so switches don't rebuild heavy screens / AsyncImages.
    private var tabContent: some View {
        ZStack {
            tabPage(.drops) { DropsFeedScreen(state: state, theme: theme) }
            tabPage(.active) { ActiveDropsScreen(state: state, theme: theme) }
            tabPage(.earnings) { EarningsScreen(state: state, theme: theme) }
            tabPage(.you) { YouProfileScreen(state: state, auth: auth, theme: theme) }
        }
    }

    private func tabPage<Content: View>(
        _ tab: AppTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let selected = state.currentTab == tab
        return content()
            .opacity(selected ? 1 : 0)
            .allowsHitTesting(selected)
            .accessibilityHidden(!selected)
            .zIndex(selected ? 1 : 0)
            .transaction { $0.animation = nil }
    }

    @ViewBuilder
    private func routeScreen(_ route: AppRoute) -> some View {
        switch route.screen {
        case .dropDetail: DropDetailScreen(state: state, opportunityID: route.id, theme: theme)
        case .proofSubmit: ProofSubmitScreen(state: state, theme: theme)
        case .editProfile: EditProfileScreen(state: state, theme: theme)
        case .payoutSettings: PayoutSettingsScreen(state: state, theme: theme)
        case .cashOut: CashOutScreen(state: state, theme: theme)
        }
    }
}

#Preview {
    ContentView()
}
