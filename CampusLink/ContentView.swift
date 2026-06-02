import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    private let theme = CLTheme.light()
    @AppStorage("onboardingDone") private var onboardingDone = false

    var body: some View {
        Group {
            if onboardingDone || appState.onboardingStep >= 5 {
                MainApp(state: appState, theme: theme)
            } else {
                OnboardingFlow(state: appState, theme: theme)
            }
        }
        .preferredColorScheme(.light)
        .onChange(of: appState.onboardingStep) { _, newValue in
            if newValue >= 5 { onboardingDone = true }
        }
    }
}

// MARK: - Onboarding Router
struct OnboardingFlow: View {
    @Bindable var state: AppState
    let theme: CLTheme

    var body: some View {
        ZStack {
            theme.bg.ignoresSafeArea()
            switch state.onboardingStep {
            case 0:
                SplashView(theme: theme) { state.onboardingStep = 1 }
                    .transition(.opacity)
            case 1:
                OnSchoolView(
                    schoolId: $state.schoolId,
                    theme: theme,
                    onNext: { state.onboardingStep = 2 },
                    onBack: { state.onboardingStep = 0 }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 2:
                OnRoleView(
                    role: Binding(get: { state.obRole }, set: { state.obRole = $0 }),
                    year: $state.year,
                    theme: theme,
                    onNext: { state.onboardingStep = 3 },
                    onBack: { state.onboardingStep = 1 }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 3:
                OnInterestsView(
                    interests: $state.interests,
                    role: state.obRole,
                    theme: theme,
                    onNext: { state.onboardingStep = 4 },
                    onBack: { state.onboardingStep = 2 }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 4:
                OnHandleView(
                    handle: $state.handle,
                    theme: theme,
                    onDone: {
                        state.appRole = state.obRole
                        withAnimation { state.onboardingStep = 5 }
                    },
                    onBack: { state.onboardingStep = 3 }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            default:
                EmptyView()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: state.onboardingStep)
    }
}

// MARK: - Main App
struct MainApp: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private let tabTopPadding: CGFloat = 28

    private var isPitchFlowActive: Bool {
        state.appRole == .org && state.currentTab == .pitch
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            theme.bg.ignoresSafeArea()

            // Tab content (hidden when stack is active, except DM)
            ZStack {
                tabContent
                    .opacity(state.navStack.isEmpty || state.navStack.last == .dm ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, isPitchFlowActive ? 0 : tabTopPadding) // pitch owns its top background

            // Stack screens
            if let screen = state.navStack.last {
                ZStack {
                    theme.bg.ignoresSafeArea()
                    stackScreen(screen)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 0)
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                .animation(.spring(response: 0.25, dampingFraction: 0.88), value: state.navStack.count)
            }

            // Toast overlay — slides in from top, auto-dismisses
            if !state.toastMessage.isEmpty {
                VStack {
                    CLToast(message: state.toastMessage, icon: state.toastIcon, theme: theme)
                        .padding(.horizontal, 24)
                        .padding(.top, 58)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: state.toastMessage)
                .zIndex(100)
            }

            // Tab bar returns when a pushed detail/popup or focused pitch flow is dismissed.
            if state.navStack.isEmpty && !isPitchFlowActive {
                VStack(spacing: 0) {
                    Spacer()
                    CLTabBar(
                        tab: Binding(get: { state.currentTab }, set: { state.setTab($0) }),
                        role: state.appRole,
                        dropPulse: state.appRole == .student && state.currentTab != .drops,
                        theme: theme,
                        onTab: { state.setTab($0) }
                    )
                    .padding(.bottom, 22)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch state.appRole {
        case .student:
            switch state.currentTab {
            case .home:   HomeScreen(state: state, theme: theme)
            case .brands: BrandsScreen(state: state, theme: theme)
            case .drops:  DropsHubScreen(state: state, theme: theme)
            case .opps:   OppsScreen(state: state, theme: theme)
            case .me:     ProfileScreen(state: state, theme: theme)
            default:      HomeScreen(state: state, theme: theme)
            }
        case .org:
            switch state.currentTab {
            case .home:   OrgHomeScreen(state: state, theme: theme)
            case .events: OrgEventsScreen(state: state, theme: theme)
            case .pitch:  PitchFlowScreen(state: state, theme: theme)
            case .opps:   OppsScreen(state: state, theme: theme)
            case .me:     ProfileScreen(state: state, theme: theme)
            default:      OrgHomeScreen(state: state, theme: theme)
            }
        }
    }

    @ViewBuilder
    private func stackScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .event:       EventDetailScreen(state: state, theme: theme)
        case .brand:       BrandDetailScreen(state: state, theme: theme)
        case .opp:         OpportunityDetailScreen(state: state, theme: theme)
        case .dm:          DMThreadScreen(state: state, theme: theme)
        case .drop:        DropRevealScreen(state: state, theme: theme)
        case .inbox:       DMInboxScreen(state: state, theme: theme)
        case .earnings:    EarningsScreen(state: state, theme: theme)
        case .editProfile: EditProfileScreen(state: state, theme: theme)
        case .dealDetail:  DealDetailScreen(state: state, theme: theme)
        }
    }
}

#Preview {
    ContentView()
}
