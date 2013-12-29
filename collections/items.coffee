itemsSchema =   
  schema:
    name:
      type: String
    class:
      type: String
      label: "stat, achievement, consumable..."
    effect:
      type: String
      label: "stat tracked, achievement required, consumable effect..."
    description:
      type: String
    flavorText:
      type: String
    karmaPrice:
      type: Number
      min: 0
    dollarPrice:
      type: Number
      min: 0
    dateCreated:
      type: Date
      label: "Date when this question was created"
    dateModified:
      type: Date
      label: "Date when this question was modified"
    rarity:
      type: String
      label: "common, uncommon, rare, legendary"
    isRandom:
      type: Boolean
      label: "Can this be found by random?"
    isShop:
      type: Boolean
      label: "Can this be purchased in shop?"


@Items = new Meteor.Collection2("items", itemsSchema)

# additional schemas: items, owned items, effect?

# item properties/effects

# index for owned item: userId