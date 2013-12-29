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
    dateModified:
      type: Date
      label: "Date when this question was modified"
    status:
      type: String
      label: "active, inactive, deleted"


ownedSkillSchema
  schema:
    userId:
      type: String
      label: "userId"
    skill:
      type: skill
    academicLevel:
      type: String
      label: "grade 12?"
    dateCreated:
      type: Date
      label: "Date when this question was created"
    dateModified:
      type: Date
      label: "Date when this question was modified"


@Skills = new Meteor.Collection2("skill", skillSchema)
@ownedSkills = new Meteor.Collection2("ownedSkill", ownedSkillSchema)

# image?
# hierarchy? prereqs?