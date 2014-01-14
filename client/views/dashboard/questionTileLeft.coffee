Template.questionTileLeft.helpers
  getSkillName: (skillId) ->
    skill = Skills.findOne(
      {_id: skillId}
    )

    if skill
      return underscoreToSpace(skill.name)

    # temporary hack to display fixture skills property
    else
      return skillId