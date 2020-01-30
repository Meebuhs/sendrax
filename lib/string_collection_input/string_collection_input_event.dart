abstract class StringCollectionInputEvent {}

class ItemAddedEvent extends StringCollectionInputEvent {
  ItemAddedEvent(this.item);

  final String item;
}

class ItemRemovedEvent extends StringCollectionInputEvent {
  ItemRemovedEvent(this.item);

  final String item;
}
