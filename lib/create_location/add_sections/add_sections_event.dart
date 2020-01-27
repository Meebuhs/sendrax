abstract class AddSectionsEvent {}

class SectionAddedEvent extends AddSectionsEvent {
  SectionAddedEvent(this.section);

  final String section;
}

class SectionRemovedEvent extends AddSectionsEvent {
  SectionRemovedEvent(this.section);

  final String section;
}
