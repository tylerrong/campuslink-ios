import SwiftUI

// MARK: - Data Models

struct School: Identifiable {
    let id: String
    let name: String
    let sub: String
    let color: Color
    let students: String
    var logoUrl: String? = nil
}

struct Interest: Identifiable {
    let id: String
    let label: String
    let icon: String  // SF Symbol name
}

struct EventDrop {
    let brand: String
    let reward: String
}

struct CLEvent: Identifiable {
    let id: String
    let org: String
    let orgKind: String
    let title: String
    let when: String
    let where_: String
    let coverGradient: [Color]
    let going: Int
    let drop: EventDrop?
}

struct Opportunity: Identifiable {
    let id: String
    let brand: String
    let title: String
    let payout: String
    let seats: String
    let deadline: String
    let accent: Color
    let accentText: Color
    let tags: [String]
    let desc: String
}

struct DM: Identifiable {
    let id: String
    let brand: String
    let last: String
    let when: String
    let unread: Int
    let accent: Color
    let accentText: Color
}

struct Brand: Identifiable {
    let id: String
    let name: String
    let cat: String
    let vibe: String
    let color: Color
    let accent: Color
    let openOpps: Int
    let activeDrops: Int
    let blurb: String
    var logoUrl: String? = nil

    var initials: String {
        name.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
    }
}

struct DealOffer: Identifiable {
    let id: String
    let brand: String
    let eventTitle: String
    let offerType: String      // "cash" | "product" | "popup" | "drop"
    let offerValue: String     // "$1,400" | "300 cans"
    let deliverables: [String]
    let expires: String
    let accent: Color
    let accentText: Color
}

struct OrgEvent: Identifiable {
    let id: String
    let title: String
    let date: String
    let kind: String
    let est: Int
    let status: OrgEventStatus
    let sponsor: String?
    let value: String?
    var offerId: String? = nil   // links to DealOffer for sponsored events

    enum OrgEventStatus: String {
        case sponsored, pitching = "open-pitch", draft
    }
}

// MARK: - Sample Data

// ESPN CDN: https://a.espncdn.com/i/teamlogos/ncaa/500/{id}.png
private func espn(_ id: Int) -> String { "https://a.espncdn.com/i/teamlogos/ncaa/500/\(id).png" }
private func brandLogo(_ domain: String) -> String { "https://logo.clearbit.com/\(domain)" }

let sampleSchools: [School] = [
    // Pac-12 / West Coast
    School(id: "usc",      name: "USC",           sub: "University of Southern California",   color: Color(hex: "990000"), students: "2.1k", logoUrl: espn(30)),
    School(id: "ucla",     name: "UCLA",           sub: "University of California, Los Angeles", color: Color(hex: "2774AE"), students: "3.4k", logoUrl: espn(26)),
    School(id: "stanford", name: "Stanford",       sub: "Stanford University",                  color: Color(hex: "8C1515"), students: "1.8k", logoUrl: espn(24)),
    School(id: "oregon",   name: "Oregon",         sub: "University of Oregon",                 color: Color(hex: "154733"), students: "1.7k", logoUrl: espn(2483)),
    School(id: "uw",       name: "Washington",     sub: "University of Washington",             color: Color(hex: "4B2E83"), students: "1.9k", logoUrl: espn(264)),
    School(id: "asu",      name: "Arizona State",  sub: "Arizona State University",             color: Color(hex: "8C1D40"), students: "2.6k", logoUrl: espn(9)),
    // Big Ten
    School(id: "umich",    name: "Michigan",       sub: "University of Michigan",               color: Color(hex: "00274C"), students: "1.9k", logoUrl: espn(130)),
    School(id: "osu",      name: "Ohio State",     sub: "The Ohio State University",            color: Color(hex: "BB0000"), students: "3.1k", logoUrl: espn(194)),
    School(id: "psu",      name: "Penn State",     sub: "Pennsylvania State University",        color: Color(hex: "041E42"), students: "2.7k", logoUrl: espn(213)),
    School(id: "wisc",     name: "Wisconsin",      sub: "University of Wisconsin-Madison",      color: Color(hex: "C5050C"), students: "2.4k", logoUrl: espn(275)),
    School(id: "iowa",     name: "Iowa",           sub: "University of Iowa",                   color: Color(hex: "FFCD00"), students: "1.7k", logoUrl: espn(2294)),
    School(id: "nebraska", name: "Nebraska",       sub: "University of Nebraska-Lincoln",       color: Color(hex: "E41C38"), students: "2.0k", logoUrl: espn(158)),
    School(id: "msu",      name: "Michigan State", sub: "Michigan State University",            color: Color(hex: "18453B"), students: "2.3k", logoUrl: espn(127)),
    School(id: "nw",       name: "Northwestern",   sub: "Northwestern University",              color: Color(hex: "4E2A84"), students: "1.3k", logoUrl: espn(77)),
    // Big 12
    School(id: "utexas",   name: "UT Austin",      sub: "University of Texas at Austin",        color: Color(hex: "BF5700"), students: "2.8k", logoUrl: espn(251)),
    School(id: "tamu",     name: "Texas A&M",      sub: "Texas A&M University",                 color: Color(hex: "500000"), students: "2.5k", logoUrl: espn(245)),
    School(id: "okla",     name: "Oklahoma",       sub: "University of Oklahoma",               color: Color(hex: "841617"), students: "2.0k", logoUrl: espn(201)),
    School(id: "ttu",      name: "Texas Tech",     sub: "Texas Tech University",                color: Color(hex: "CC0000"), students: "2.1k", logoUrl: espn(2641)),
    School(id: "baylor",   name: "Baylor",         sub: "Baylor University",                    color: Color(hex: "154734"), students: "1.7k", logoUrl: espn(239)),
    // SEC
    School(id: "alabama",  name: "Alabama",        sub: "University of Alabama",                color: Color(hex: "9E1B32"), students: "2.9k", logoUrl: espn(333)),
    School(id: "georgia",  name: "Georgia",        sub: "University of Georgia",                color: Color(hex: "BA0C2F"), students: "2.4k", logoUrl: espn(61)),
    School(id: "uf",       name: "Florida",        sub: "University of Florida",                color: Color(hex: "0021A5"), students: "2.6k", logoUrl: espn(57)),
    School(id: "lsu",      name: "LSU",            sub: "Louisiana State University",           color: Color(hex: "461D7C"), students: "2.2k", logoUrl: espn(99)),
    School(id: "tenn",     name: "Tennessee",      sub: "University of Tennessee",              color: Color(hex: "FF8200"), students: "2.1k", logoUrl: espn(2633)),
    School(id: "auburn",   name: "Auburn",         sub: "Auburn University",                    color: Color(hex: "03244D"), students: "1.8k", logoUrl: espn(2)),
    School(id: "vandy",    name: "Vanderbilt",     sub: "Vanderbilt University",                color: Color(hex: "866D4B"), students: "1.3k", logoUrl: espn(238)),
    School(id: "kentucky", name: "Kentucky",       sub: "University of Kentucky",               color: Color(hex: "005DAA"), students: "1.9k", logoUrl: espn(96)),
    // ACC
    School(id: "duke",     name: "Duke",           sub: "Duke University",                      color: Color(hex: "003087"), students: "1.4k", logoUrl: espn(150)),
    School(id: "unc",      name: "UNC",            sub: "University of North Carolina",         color: Color(hex: "4B9CD3"), students: "2.2k", logoUrl: espn(153)),
    School(id: "clemson",  name: "Clemson",        sub: "Clemson University",                   color: Color(hex: "F56600"), students: "2.0k", logoUrl: espn(228)),
    School(id: "fsu",      name: "Florida State",  sub: "Florida State University",             color: Color(hex: "782F40"), students: "2.3k", logoUrl: espn(52)),
    School(id: "miami",    name: "Miami",          sub: "University of Miami",                  color: Color(hex: "005030"), students: "1.6k", logoUrl: espn(2390)),
    // Independents
    School(id: "nd",       name: "Notre Dame",     sub: "University of Notre Dame",             color: Color(hex: "0C2340"), students: "1.6k", logoUrl: espn(87)),
]

// Student signup — campaign + opportunity focused
let studentInterests: [Interest] = [
    Interest(id: "campaigns",   label: "Brand campaigns",     icon: "megaphone.fill"),
    Interest(id: "ambassador",  label: "Ambassador programs", icon: "star.fill"),
    Interest(id: "ugc",         label: "UGC + content",       icon: "camera.fill"),
    Interest(id: "paid",        label: "Paid gigs",           icon: "dollarsign"),
    Interest(id: "freeproduct", label: "Free product",        icon: "gift.fill"),
    Interest(id: "eventdrops",  label: "Event drops",         icon: "bolt.fill"),
    Interest(id: "tabling",     label: "Tabling + pop-ups",   icon: "mappin.circle.fill"),
    Interest(id: "merch",       label: "Merch + streetwear",  icon: "tshirt.fill"),
    Interest(id: "foodbev",     label: "Food + bev brands",   icon: "cup.and.saucer.fill"),
    Interest(id: "internships", label: "Internships",         icon: "briefcase.fill"),
    Interest(id: "tech",        label: "Tech + apps",         icon: "iphone"),
    Interest(id: "wellness",    label: "Wellness brands",     icon: "heart.fill"),
]

// Org admin signup — sponsorship + partnership focused
let orgInterests: [Interest] = [
    Interest(id: "eventspons",  label: "Event sponsorships",  icon: "ticket.fill"),
    Interest(id: "brandpart",   label: "Brand partnerships",  icon: "handshake.fill"),
    Interest(id: "paidactivate",label: "Paid activations",    icon: "dollarsign"),
    Interest(id: "freeprod",    label: "Free product",        icon: "gift.fill"),
    Interest(id: "social",      label: "Social collabs",      icon: "bubble.left.and.bubble.right.fill"),
    Interest(id: "philanthropy",label: "Philanthropy support", icon: "heart.fill"),
    Interest(id: "rush",        label: "Rush + recruitment",  icon: "person.3.fill"),
    Interest(id: "community",   label: "Community building",  icon: "building.2.fill"),
    Interest(id: "swag",        label: "Merch + swag",        icon: "tshirt.fill"),
    Interest(id: "foodcater",   label: "Food + catering",     icon: "fork.knife"),
]

// Legacy alias — kept so any other reference doesn't break
let sampleInterests: [Interest] = studentInterests

// Pitch audience descriptors — who attends this event?
let audienceInterests: [Interest] = [
    Interest(id: "greek",      label: "Greek life",        icon: "sparkles"),
    Interest(id: "athletes",   label: "Athletes",          icon: "figure.run"),
    Interest(id: "stem",       label: "STEM crowd",        icon: "flask.fill"),
    Interest(id: "business",   label: "Business students", icon: "briefcase.fill"),
    Interest(id: "artsy",      label: "Arts + culture",    icon: "paintpalette.fill"),
    Interest(id: "wellness",   label: "Health + wellness", icon: "heart.fill"),
    Interest(id: "partiers",   label: "Party crowd",       icon: "party.popper.fill"),
    Interest(id: "premeds",    label: "Pre-med / bio",     icon: "stethoscope"),
    Interest(id: "law",        label: "Pre-law",           icon: "building.columns.fill"),
    Interest(id: "outdoors",   label: "Outdoors / active", icon: "mountain.2.fill"),
    Interest(id: "foodies",    label: "Food obsessed",     icon: "fork.knife"),
    Interest(id: "techies",    label: "Tech / startup",    icon: "cpu.fill"),
]

let sampleEvents: [CLEvent] = [
    CLEvent(id: "sigeprose",       org: "Sig Ep",            orgKind: "Fraternity", title: "Rose Formal",      when: "Fri · Apr 12 · 9PM",  where_: "The Wiltern",      coverGradient: [Color(hex: "FF1F1F"), Color(hex: "B30000")], going: 312, drop: EventDrop(brand: "Liquid Death", reward: "free 4-pack at the door")),
    CLEvent(id: "tridelt-philanthropy", org: "Tri Delt",     orgKind: "Sorority",   title: "Delta Dash 5K",    when: "Sat · Apr 13 · 8AM",  where_: "Exposition Park",  coverGradient: [Color(hex: "FFD60A"), Color(hex: "FF8A00")], going: 187, drop: EventDrop(brand: "Celsius",     reward: "finisher 12-pack")),
    CLEvent(id: "club-techweek",   org: "USC Startup Society",orgKind: "Club",      title: "TechWeek Pitch Night",when: "Wed · Apr 17 · 7PM",where_: "Cromwell Field",   coverGradient: [Color(hex: "0E0B0B"), Color(hex: "2A1F1F")], going: 96,  drop: nil),
    CLEvent(id: "aphi-coffee",     org: "Alpha Phi",         orgKind: "Sorority",   title: "Coffee + Crepes",  when: "Sun · Apr 14 · 10AM", where_: "AΦ House",         coverGradient: [Color(hex: "FFC0D9"), Color(hex: "FF6B9B")], going: 64,  drop: EventDrop(brand: "Olipop",      reward: "free can + sticker")),
]

let sampleOpportunities: [Opportunity] = [
    Opportunity(id: "liquid-death-ambo", brand: "Liquid Death", title: "Campus Ambassador · Spring drop", payout: "$400 + product",    seats: "8 spots",    deadline: "3d left",  accent: Color(hex: "0E0B0B"), accentText: .white,             tags: ["Ambassador","Content","4 weeks"], desc: "Run two on-campus sampling activations and post 3 organic IG Reels. Murder your thirst, get paid."),
    Opportunity(id: "celsius-tabling",   brand: "Celsius",      title: "Game day tabling",               payout: "$250",              seats: "4 spots",    deadline: "6d left",  accent: Color(hex: "FFD60A"), accentText: Color(hex: "1a0e0e"), tags: ["Tabling","1 day"],               desc: "Sample Celsius outside the Coliseum gates 2 hours before kickoff."),
    Opportunity(id: "duolingo-streak",   brand: "Duolingo",     title: "Streak Challenge · 21 days",     payout: "$50 + merch",       seats: "120 spots",  deadline: "12d left", accent: Color(hex: "58CC02"), accentText: .white,             tags: ["Challenge","Solo","In-app"],     desc: "Hit a 21-day streak and post your owl. Top 3 finishers get an extra $200."),
    Opportunity(id: "olipop-popup",      brand: "Olipop",       title: "Sorority pop-up sponsor",        payout: "$1.2k for the chapter", seats: "1 chapter", deadline: "1w left", accent: Color(hex: "FF6B9B"), accentText: .white,            tags: ["Sponsorship","Org-only"],        desc: "Co-brand your next philanthropy event. Olipop covers product + signage."),
]

let sampleDMs: [DM] = [
    DM(id: "liquid-death", brand: "Liquid Death", last: "sick. we ship the swag tomorrow 💀", when: "2m",   unread: 2, accent: Color(hex: "0E0B0B"), accentText: .white),
    DM(id: "celsius",      brand: "Celsius",      last: "Can you do Saturday at 11?",          when: "1h",   unread: 0, accent: Color(hex: "FFD60A"), accentText: Color(hex: "1a0e0e")),
    DM(id: "duolingo",     brand: "Duolingo",     last: "streak day 14 — keep going!",         when: "3h",   unread: 1, accent: Color(hex: "58CC02"), accentText: .white),
    DM(id: "olipop",       brand: "Olipop",       last: "love the chapter pitch deck",         when: "yest", unread: 0, accent: Color(hex: "FF6B9B"), accentText: .white),
]

let sampleBrands: [Brand] = [
    Brand(id: "liquid-death", name: "Liquid Death", cat: "Beverage", vibe: "irreverent", color: Color(hex: "0E0B0B"), accent: .white,                    openOpps: 3, activeDrops: 1, blurb: "murder your thirst — looking for ambassadors who post", logoUrl: brandLogo("liquiddeath.com")),
    Brand(id: "celsius",      name: "Celsius",      cat: "Beverage", vibe: "fitness",    color: Color(hex: "FFD60A"), accent: Color(hex: "1a0e0e"),       openOpps: 4, activeDrops: 2, blurb: "energy that hits — game day tabling + content", logoUrl: brandLogo("celsius.com")),
    Brand(id: "duolingo",     name: "Duolingo",     cat: "App",      vibe: "unhinged",   color: Color(hex: "58CC02"), accent: .white,                    openOpps: 2, activeDrops: 1, blurb: "the owl is watching — streak challenges all spring", logoUrl: brandLogo("duolingo.com")),
    Brand(id: "olipop",       name: "Olipop",       cat: "Beverage", vibe: "wellness",   color: Color(hex: "FF6B9B"), accent: .white,                    openOpps: 5, activeDrops: 0, blurb: "modern soda for the org that vibes — sponsoring pop-ups", logoUrl: brandLogo("drinkolipop.com")),
    Brand(id: "chipotle",     name: "Chipotle",     cat: "Food",     vibe: "always-on",  color: Color(hex: "A81612"), accent: .white,                    openOpps: 1, activeDrops: 1, blurb: "free bowls for chapters that show up", logoUrl: brandLogo("chipotle.com")),
    Brand(id: "cashapp",      name: "Cash App",     cat: "Finance",  vibe: "culture",    color: Color(hex: "00D632"), accent: Color(hex: "1a0e0e"),       openOpps: 2, activeDrops: 0, blurb: "sending $$ to orgs that move money on campus", logoUrl: brandLogo("cash.app")),
]

let sampleOffers: [DealOffer] = [
    DealOffer(
        id: "celsius-formal",
        brand: "Celsius",
        eventTitle: "Rose Formal",
        offerType: "cash",
        offerValue: "$1,400",
        deliverables: ["IG story at entry", "sample 200+ guests", "mention in chapter email blast"],
        expires: "48h left",
        accent: Color(hex: "FFD60A"),
        accentText: Color(hex: "1a0e0e")
    ),
    DealOffer(
        id: "liquid-death-dash",
        brand: "Liquid Death",
        eventTitle: "Delta Dash 5K",
        offerType: "product",
        offerValue: "300 cans",
        deliverables: ["finisher photo post on IG", "logo on race bib"],
        expires: "3d left",
        accent: Color(hex: "0E0B0B"),
        accentText: .white
    ),
]

let sampleOrgEvents: [OrgEvent] = [
    OrgEvent(id: "rose-formal-25",   title: "Rose Formal",       date: "Apr 12", kind: "Formal",      est: 350, status: .sponsored, sponsor: "Celsius",      value: "$1,400", offerId: "celsius-formal"),
    OrgEvent(id: "philanthropy-5k",  title: "Delta Dash 5K",     date: "Apr 13", kind: "Philanthropy", est: 200, status: .pitching,  sponsor: nil,            value: nil),
    OrgEvent(id: "rush-week-26",     title: "Rush Week Kickoff", date: "Aug 24", kind: "Recruitment", est: 500, status: .draft,     sponsor: nil,            value: nil),
    OrgEvent(id: "date-party",       title: "Date Party · Disco",date: "May 3",  kind: "Social",      est: 120, status: .pitching,  sponsor: nil,            value: nil),
]
