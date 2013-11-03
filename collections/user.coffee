Users = new Meteor.Collection2("users",
  schema:
    firstName:
      type: String
      label: "First name"
      max: 200
    lastName:
      type: String
      label: "Last name"
      max: 200
    karma:
      type: Number
      label: "Karma"
      min: 0
    dateCreated:
      type: Date
      label: "Date when this question was created"
    dateModified:
      type: Date
      label: "Date when this question was modified"
  virtualFields: 
    fullName: (person) ->
      return person.firstName + ", " + person.lastName
)

# Users.allow
#   insert: (name, email) ->
#     false # no cowboy inserts -- use createParty method