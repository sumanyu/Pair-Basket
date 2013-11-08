@Questions = new Meteor.Collection("questions")

# We might use Collection2 later
# @Questions = new Meteor.Collection2("questions",
#   schema:
#     title:
#       type: String
#       label: "Title"
#       max: 200
#     userId:
#       type: String
#       label: "userId"
#     category:
#       type: String
#     tags:
#       type: [String]
#     karmaOffered:
#       type: Number
#       label: "Karma offered"
#       min: 0
#     dateCreated:
#       type: Date
#       label: "Date when this question was created"
#     dateModified:
#       type: Date
#       label: "Date when this question was modified"
#     status:
#       type: String
#       label: "Resolved, Inactive, Expired, Deleted"
#   virtualFields: 
#     tagsJoined: (question) ->
#       question.tags.reduce (current, total) -> "#{total}, #{current}"
# )