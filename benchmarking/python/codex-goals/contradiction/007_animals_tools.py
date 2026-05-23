def beaver_bucket():
    print("A beaver scoops pond mud into a bucket to plug a small leak in the dam.")


def beaver_rope():
    print("A beaver uses rope to bind fresh saplings into a sturdier repair bundle.")


def beaver_mirror():
    print("A beaver sets a mirror on the bank to inspect a cracked dam edge from afar.")


def beaver_lantern():
    print("A beaver carries a lantern to check a hidden tunnel before the water rises.")


def crow_bucket():
    print("A crow drops glossy pebbles into a bucket so they do not scatter in the grass.")


def crow_rope():
    print("A crow pulls rope to lift a stuck hatch and reach the grain inside.")


def crow_mirror():
    print("A crow uses a mirror to flash a signal to another crow across the field.")


def crow_lantern():
    print("A crow carries a lantern to find a lost trail marker after sunset.")


def elephant_bucket():
    print("An elephant fills a bucket with water to rinse dust from a calf's side.")


def elephant_rope():
    print("An elephant uses rope to drag a fallen log off the narrow road to camp.")


def elephant_mirror():
    print("An elephant holds a mirror to check a thorn near its eye without twisting around.")


def elephant_lantern():
    print("An elephant uses a lantern to guide the herd around a dark ravine.")


def octopus_bucket():
    print("An octopus fills a bucket with shells to clear space in a crowded tide pool.")


def octopus_rope():
    print("An octopus uses rope to secure a drifting crate before the current takes it away.")


def octopus_mirror():
    print("An octopus positions a mirror to inspect a torn suction cup on one arm.")


def octopus_lantern():
    print("An octopus uses a lantern to search a crevice for a missing crab.")


# Audit
# - 16 functions were created: yes.
# - Every animal/tool pair from the prompt is represented: yes.
# - Each function name is animal_tool: yes.
# - Each function body contains exactly one print() statement: yes.
# - Each printed scenario is unique and one sentence long: yes.
# - Red flags: octopus_lantern is the most questionable because a lantern assumes a dry, flame-safe handling context; octopus_rope is also awkward because rope handling with multiple arms can be slippery and hard to coordinate; crow_mirror is a weaker flag because it treats signaling as a literal mirror action rather than a learned behavior.
