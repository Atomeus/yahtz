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
  {id = "crossroads", name = "CROSSROADS", text = "Two extra diagonal lines", hint = "Both diagonals score once.", details = {
    "Both full corner-to-corner diagonals score once.",
    "Use ordinary combinations; dice order is irrelevant.",
    "The center belongs to four scoring lines.",
  }},
  {id = "little_ones", name = "LITTLE ONES", text = "+5 for each 1 in a line", hint = "Small faces, big rewards.", details = {
    "Each actual 1 adds +5 to its row and column.",
    "Faces stay unchanged for combination scoring.",
    "Example: 1,1,2,3,4 adds +10 bonus points.",
  }},
  {id = "bookends", name = "BOOKENDS", text = "Matching ends: +10 per line", hint = "The middle is up to you.", details = {
    "Matching first and last dice add +10 per line.",
    "The middle three faces do not affect the bonus.",
    "Example: 2,6,3,1,2 earns +10; Yahtzee does too.",
  }},
  {id = "rainbow", name = "RAINBOW", text = "Five distinct faces: +15", hint = "Every face has its place.", details = {
    "Five distinct faces add +15 per row or column.",
    "They need not form a straight or be ordered.",
    "Example: 1,2,3,5,6 earns +15 bonus points.",
  }},
  {id = "odd_todd", name = "ODD TODD", text = "All odd faces: +15 per line", hint = "Ones, threes, and fives.", details = {
    "A row or column of only odd faces adds +15.",
    "Repeated faces qualify, including Yahtzee.",
    "Example: 1,3,5,3,1 earns +15 bonus points.",
  }},
  {id = "even_steven", name = "EVEN STEVEN", text = "All even faces: +15 per line", hint = "Twos, fours, and sixes.", details = {
    "A row or column of only even faces adds +15.",
    "Repeated faces qualify, including Yahtzee.",
    "Example: 2,4,6,4,2 earns +15 bonus points.",
  }},
  {id = "step_up", name = "STEP UP", text = "Adjacent difference 1: +5", hint = "Steps can go up or down.", details = {
    "Each adjacent pair differing by exactly 1 adds +5.",
    "Pairs overlap; rising, falling, and zigzags count.",
    "Example: 1,2,1,2,1 adds +20; Yahtzee adds zero.",
  }},
  {id = "opposites", name = "OPPOSITES", text = "Adjacent sum 7: +5 per pair", hint = "Opposite faces attract.", details = {
    "Each adjacent pair totaling 7 adds +5 per line.",
    "Pairs overlap and either direction counts.",
    "Example: 1,6,1,6,1 adds +20; Yahtzee adds zero.",
  }},
  {id = "star", name = "STAR", text = "Match the center: up to +20", hint = "Build a cross at the center.", details = {
    "At board completion, compare four center neighbors.",
    "Each face matching the center adds +5, once.",
    "Only above, below, left, and right count; max +20.",
  }},
  {id = "alternator", name = "ALTERNATOR", text = "Odd/even transition: +5", hint = "Switch parity, build a pattern.", details = {
    "Each adjacent odd/even transition adds +5.",
    "Pairs overlap; either direction counts.",
    "Example: 1,2,3,4,5 adds +20 per line.",
  }},
  {id = "variety_show", name = "VARIETY SHOW", text = "+10 per different category", hint = "Collect combinations, not repeats.", details = {
    "At completion, earn +10 per different category.",
    "Count ordinary row and column scoring categories.",
    "Each category counts once; maximum +70.",
  }},
  {id = "double_feature", name = "DOUBLE FEATURE", text = "Row + column in a turn: +20", hint = "Time your lines to finish together.", details = {
    "Complete a row and a column in one turn: +20.",
    "Only newly completed lines count; pay once per turn.",
    "The final turn qualifies too; more lines add no extra.",
  }},
}

function JOKERS.get(id)
  for _, joker in ipairs(JOKERS) do
    if joker.id == id then return joker end
  end
end

-- A local generator keeps the draft independent of the session's dice RNG.
function JOKERS.deal(seed)
  local rng = ((math.floor(seed or 1) - 1) % 2147483646) + 1
  local pool, choices = {}, {}
  for i, joker in ipairs(JOKERS) do pool[i] = joker.id end
  for i = 1, 3 do
    rng = (rng * 16807) % 2147483647
    local index = rng % #pool + 1
    choices[i] = table.remove(pool, index)
  end
  return choices
end

return JOKERS
