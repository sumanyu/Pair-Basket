skillSchema =   
  schema:
    category:
      type: String
      label: "math, science, english, social_science, computers, business, foreign_language"
      max: 200
    tags:
      type: [String]
      label: "calculus?"
    name:
      type: String
      label: "integrals"
    description:
      type: String
      label: "integration is a fundamental technique in calculus"
    dateCreated:
      type: Date
      label: "Date when this question was created"
    status:
      type: String
      label: "available, disabled"

@Skills = new Meteor.Collection2("skill", skillSchema)

# ownedSkillSchema =
#   schema:
#     userId:
#       type: String
#       label: "userId"
#     skillId:
#       type: String
#     academicLevel:
#       type: String
#       label: "grade 12?"
#     dateCreated:
#       type: Date
#       label: "Date when this question was created"
#     display:
#       type: Boolean
#       label: "Display in profile?"


# @OwnedSkills = new Meteor.Collection2("ownedSkill", ownedSkillSchema)

# image?
# hierarchy? prereqs?
# skill tags?