import json
import sys
import pyperclip

def processNotes(data, bpm, diff):
    beatTime = ((60 / bpm) * 1000)
    sectionTime = beatTime * 4
    stepTime = beatTime / 4
    curSectionTime = 0

    sections = [[]]
    curSection = 0
    
    for note in data["notes"][diff]:
        while(note["t"] >= curSectionTime + (sectionTime * 0.99)):
            curSectionTime += sectionTime
            curSection += 1
            sections.append([])
        l = 0
        k = ""  
        if "l" in note:
            if note["l"] > 0:
                lengthCount = 0
                while True:
                    if note["l"] > (stepTime * lengthCount) + stepTime * 0.9:
                        l += stepTime
                        lengthCount += 1
                    else:
                        break
                l = round(l)
                print("Hold Duration " + str(round(note["l"])) + "\t>\t" + str(l))
        if "k" in note:
            k = note["k"]
        sections[curSection].append([note["t"], note["d"], l, k])

    output = "\"notes\": ["

    for section in sections:

        output += "\n{\n\"lengthInSteps\": 16,\n\"sectionNotes\": [\n"

        for note in section:

            output += "[" + str(note[0]) + "," + str(note[1]) + "," + str(note[2]) + ",\"" + str(note[3]) + "\"],"
        
        output = output[:-1]
        output += "\n],\n\"bpm\": 0,\n\"changeBPM\": null,\n\"mustHitSection\": true\n},"

    output = output[:-1]

    output += "\n],"

    return output


if(__name__ == "__main__"):
    print("Difficulty: ")
    inputDiff = input()

    print("BPM: ")
    inputBPM = float(input())

    f = open(sys.argv[1])
    chartJson = json.load(f)
    f.close()

    result = processNotes(chartJson, inputBPM, inputDiff)

    pyperclip.copy(result)
    print("notes copied to clipbaord!!")