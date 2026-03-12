import 'people_models.dart';

class PeopleDummyData {
  // ✅ LOCKED for demo: always show the filled People UI
  static const bool hasPeople = true;

  static const List<Person> innerCircle = [
    Person(
      id: "p1",
      name: "Sean L.",
      handle: "@seanl",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "1 month ago",
      moodChip: "Beginner",
      tint: "blue",
    ),
    Person(
      id: "p2",
      name: "James K.",
      handle: "@jamesk",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "1 month ago",
      moodChip: "Intermediate",
      tint: "green",
    ),
    Person(
      id: "p3",
      name: "Kathleen",
      handle: "@kathleen",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "3 days ago",
      moodChip: "Beginner",
      tint: "purple",
    ),
    Person(
      id: "p4",
      name: "Lily M.",
      handle: "@lilym",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "2 weeks ago",
      moodChip: "Intermediate",
      tint: "pink",
    ),
    Person(
      id: "p5",
      name: "Zira S.",
      handle: "@ziras",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "2 weeks ago",
      moodChip: "Intermediate",
      tint: "yellow",
    ),
    Person(
      id: "p6",
      name: "Annie Chao",
      handle: "@annie",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "2 weeks ago",
      moodChip: "Expert",
      tint: "blue",
    ),
  ];

  static const List<Person> connections = [
    Person(
      id: "c1",
      name: "Kathleen",
      handle: "@kathleen",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "3 days ago",
      moodChip: "Sad",
      tint: "purple",
    ),
    Person(
      id: "c2",
      name: "Lily M.",
      handle: "@lilym",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "2 weeks ago",
      moodChip: "Surprised",
      tint: "orange",
    ),
    Person(
      id: "c3",
      name: "Jacob S.",
      handle: "@jacobs",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "1 month ago",
      moodChip: "Disappointed",
      tint: "green",
    ),
    Person(
      id: "c4",
      name: "Sean L.",
      handle: "@seanl",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "1 month ago",
      moodChip: "Embarrassed",
      tint: "blue",
    ),
  ];

  static const List<Person> suggestions = [
    Person(
      id: "s1",
      name: "James Carter",
      handle: "@james",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "2 weeks ago",
      moodChip: "Embarrassed",
      tint: "blue",
    ),
    Person(
      id: "s2",
      name: "Henry C.",
      handle: "@henry",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "6 days ago",
      moodChip: "",
      tint: "grey",
    ),
    Person(
      id: "s3",
      name: "Sean K.",
      handle: "@seank",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "1 month ago",
      moodChip: "Disappointed",
      tint: "green",
    ),
    Person(
      id: "s4",
      name: "Arya Singh",
      handle: "@arya",
      avatarUrl: "",
      location: "Los Angeles, CA",
      lastActive: "1 month ago",
      moodChip: "",
      tint: "pink",
    ),
  ];

  static const List<ConnectionRequest> requests = [
    ConnectionRequest(
      id: "r1",
      person: Person(
        id: "rq1",
        name: "Gretchen Geidt",
        handle: "@gretchen_g",
        avatarUrl: "",
        location: "Los Angeles, CA",
        lastActive: "",
        moodChip: "",
        tint: "purple",
      ),
    ),
    ConnectionRequest(
      id: "r2",
      person: Person(
        id: "rq2",
        name: "Aspen Calzoni",
        handle: "@calzoni_ap",
        avatarUrl: "",
        location: "Los Angeles, CA",
        lastActive: "",
        moodChip: "",
        tint: "grey",
      ),
    ),
    ConnectionRequest(
      id: "r3",
      person: Person(
        id: "rq3",
        name: "Kaylon Singh",
        handle: "@kaysingh1",
        avatarUrl: "",
        location: "Los Angeles, CA",
        lastActive: "",
        moodChip: "",
        tint: "purple",
      ),
    ),
    ConnectionRequest(
      id: "r4",
      person: Person(
        id: "rq4",
        name: "Jordyn Rosser",
        handle: "@jjjrrrrrosser",
        avatarUrl: "",
        location: "Los Angeles, CA",
        lastActive: "",
        moodChip: "",
        tint: "green",
      ),
    ),
  ];

  static const List<ChatMessage> chat = [
    ChatMessage(
      id: "m1",
      text:
          "Hi James! I want to ask you a question. Is there a way for us to create a group chat for Yoga?",
      isMe: true,
      time: "12m",
    ),
    ChatMessage(
      id: "m2",
      text: "Can’t wait to meet everyone!",
      isMe: true,
      time: "11m",
    ),
    ChatMessage(
      id: "m3",
      text:
          "Hi Lily! Yeah I would love to join the yoga group and I can ask people to join us!",
      isMe: false,
      time: "10m",
    ),
    ChatMessage(
      id: "m4",
      text: "I’ll create one and invite you!",
      isMe: false,
      time: "8m",
    ),
    ChatMessage(
      id: "m5",
      text: "Great! Looking forward to the yoga group!",
      isMe: true,
      time: "1m",
    ),
  ];
}
