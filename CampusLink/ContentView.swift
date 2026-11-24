import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    private let theme = CLTheme.light()
    @AppStorage("onboardingDone") private var onboardingDone = false

    var body: some View {
        Group {
            if onboardingDone || appState.onboardingStep >= 6 {
                MainApp(state: appState, theme: theme)
            } else {
                OnboardingFlow(state: appState, theme: theme)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .preferredColorScheme(.light)
        .onChange(of: appState.onboardingStep) { _, newValue in
            if newValue >= 6 { onboardingDone = true }
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
                OnRoleView(
                    profileKind: $state.profileKind,
                    theme: theme,
                    onNext: { state.onboardingStep = 2 },
                    onBack: { state.onboardingStep = 0 }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 2:
                OnSchoolView(
                    schoolId: $state.schoolId,
                    year: $state.year,
                    showYear: state.profileKind == .student,
                    theme: theme,
                    onNext: { state.onboardingStep = 3 },
                    onBack: { state.onboardingStep = 1 }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 3:
                OnVerifyView(
                    eduEmail: $state.eduEmail,
                    verificationStatus: $state.verificationStatus,
                    schoolName: state.school.name,
                    theme: theme,
                    onNext: { state.onboardingStep = 4 },
                    onBack: { state.onboardingStep = 2 },
                    onSubmit: { email in state.submitVerification(email: email) }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 4:
                Group {
                    if state.profileKind == .student {
                        OnInterestsView(
                            interests: $state.interests,
                            theme: theme,
                            onNext: { state.onboardingStep = 5 },
                            onBack: { state.onboardingStep = 3 }
                        )
                    } else {
                        OnOrgDetailsView(
                            orgName: $state.orgName,
                            orgType: $state.orgType,
                            orgMemberCount: $state.orgMemberCount,
                            theme: theme,
                            onNext: { state.onboardingStep = 5 },
                            onBack: { state.onboardingStep = 3 }
                        )
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 5:
                OnHandleView(
                    handle: $state.handle,
                    isOrg: state.profileKind == .org,
                    orgName: state.orgName,
                    theme: theme,
                    onDone: {
                        withAnimation { state.onboardingStep = 6 }
                    },
                    onBack: { state.onboardingStep = 4 }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            default:
                EmptyView()
            }
        }
        .animation(.easeOut(duration: 0.28), value: state.onboardingStep)
    }
}

// MARK: - Main App
struct MainApp: View {
    @Bindable var state: AppState
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
                // Root: gesture attached but won't begin (stack depth == 1).
                .clInteractivePopGesture()
                .navigationDestination(for: AppRoute.self) { route in
                    routeScreen(route)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                        .toolbarBackground(.hidden, for: .navigationBar)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // Destinations: re-enable system edge swipe-back under hidden back button.
                        .clInteractivePopGesture()
                        .overlay(alignment: .leading) {
                            // Narrow leading-edge fallback if UIKit pop isn't attached yet.
                            Color.clear
                                .frame(width: 20)
                                .frame(maxHeight: .infinity)
                                .contentShape(Rectangle())
                                .highPriorityGesture(
                                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                        .onEnded { value in
                                            let swipedRight = value.translation.width > 70
                                            let mostlyHorizontal = abs(value.translation.width) > abs(value.translation.height) * 1.2
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
    }

    /// Keep all tab roots alive so switches don't rebuild heavy screens / AsyncImages.
    private var tabContent: some View {
        ZStack {
            tabPage(.drops) { DropsFeedScreen(state: state, theme: theme) }
            tabPage(.active) { ActiveDropsScreen(state: state, theme: theme) }
            tabPage(.earnings) { EarningsScreen(state: state, theme: theme) }
            tabPage(.you) { YouProfileScreen(state: state, theme: theme) }
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
            // Keep page swaps instant even when the tab bar animates.
            .transaction { $0.animation = nil }
    }

    @ViewBuilder
    private func routeScreen(_ route: AppRoute) -> some View {
        switch route.screen {
        case .dropDetail: DropDetailScreen(state: state, theme: theme)
        case .proofSubmit: ProofSubmitScreen(state: state, theme: theme)
        case .notifications: NotificationsScreen(state: state, theme: theme)
        case .verification: VerificationScreen(state: state, theme: theme)
        case .editProfile: EditProfileScreen(state: state, theme: theme)
        case .payoutSettings: PayoutSettingsScreen(state: state, theme: theme)
        case .cashOut: CashOutScreen(state: state, theme: theme)
        }
    }
}

#Preview {
    ContentView()
}
