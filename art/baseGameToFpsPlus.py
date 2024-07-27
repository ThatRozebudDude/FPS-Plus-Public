import json
import sys
import pyperclip
 
f = open(sys.argv[1])
 
data = json.load(f)

print("Difficulty: ")
diff = input()

print("BPM: ")
bpm = float(input())
sectionTime = ((60 / bpm) * 1000) * 4
curSectionTime = 0

sections = [[]]
curSection = 0
 
for note in data["notes"][diff]:
    while(note["t"] >= curSectionTime + (sectionTime * 0.99)):
        curSectionTime += sectionTime
        curSection += 1
        sections.append([])
    k = ""
    if "k" in note:
        k = note["k"]
    sections[curSection].append([note["t"], note["d"], note["l"], k])

f.close()

output = "\"notes\": ["

for section in sections:

    output += "\n{\n\"lengthInSteps\": 16,\n\"sectionNotes\": [\n"

    for note in section:

        output += "[" + str(note[0]) + "," + str(note[1]) + "," + str(note[2]) + ",\"" + str(note[3]) + "\"],"
    
    output = output[:-1]
    output += "\n],\n\"bpm\": 0,\n\"changeBPM\": null,\n\"mustHitSection\": true\n},"

output = output[:-1]

output += "\n],"

pyperclip.copy(output)
print("notes copied to clipbaord!!")