local JOKERS = {
  { id = "pair_pay", name = "PAIR PAY", text = "+10 for every repeated face", hint = "Pairs and triples all pay.", details = {
    "Each distinct repeated face adds +10 per line.",
    "Triples, four of a kind and Yahtzee count too.",
    "Example: 2,2,5,5,5 adds +20 bonus points.",
  } },
  { id = "short_run", name = "SHORT RUN", text = "Any four distinct faces: 30", hint = "Build little runs your own way.", details = {
    "Any four distinct faces qualify for 30 points.",
    "Example: 1,2,4,6,6 is a small straight.",
    "A natural large straight still scores 40.",
  } },
  { id = "thrifty", name = "THRIFTY", text = "+5 for each unused roll", hint = "Keep your rolls. Keep the change.", details = {
    "+5 per unused roll when confirming a turn.",
    "Stop after the first roll for +10 points.",
    "One reroll: +5. Both rerolls: no bonus.",
  } },
}

function JOKERS.get(id)
  for _, joker in ipairs(JOKERS) do
    if joker.id == id then return joker end
  end
end

return JOKERS
