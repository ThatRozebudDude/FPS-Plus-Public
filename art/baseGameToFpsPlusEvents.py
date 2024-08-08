import json
import sys
import pyperclip
 
f = open(sys.argv[1])
 
data = json.load(f)

print("BPM: ")
bpm = float(input())
sectionTime = ((60 / bpm) * 1000) * 4
curSectionTime = 0

curSection = 0

output = "{\"events\":{\"events\":[\n"
output += "[0, 0, 3, \"toggleCamMovement\"]\n"

for event in data["events"]:
    while(event["t"] >= curSectionTime + (sectionTime * 0.99)):
        curSectionTime += sectionTime
        curSection += 1
    
    skipAdd = False

    eventToAdd = ",[" + str(curSection) + ", " + str(event["t"]) + ", 0, "

    tag = ""

    match event["e"]:
        case "FocusCamera":
            match event["v"]["char"]:
                    case 0 | "0":
                        tag += "camFocusBf;"
                    case 1 | "1":
                        tag += "camFocusDad;"
                    case 2 | "2":
                        tag += "camFocusGf;"
                        
            tag += str(event["v"]["x"]) + ";" + str(event["v"]["y"])

            if "ease" in event["v"]:
                if not event["v"]["ease"] == "CLASSIC":
                    tag += ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"])

            print(event["e"] + "\t->\t" + tag)

        case "ZoomCamera":
            tag += "camZoom;" + str(event["v"]["zoom"]) + ";" + str(event["v"]["duration"]) + "s;" + event["v"]["ease"]

            if "mode" in event["v"]:
                if event["v"]["mode"] == "stage":
                    tag += ";true"

            print(event["e"] + "\t->\t" + tag)

        case "SetCameraBop":
            #does not support intensity
            tag += "camBopFreq;" + str(event["v"]["rate"])
            print(event["e"] + "\t->\t" + tag)

        case _:
            skipAdd = True
            print("Event not supported, skipping.")

    if not skipAdd:
        eventToAdd += "\"" + tag + "\"]"
        output += eventToAdd + "\n"

output += "]}}"
 
pyperclip.copy(output)
print("events copied to clipbaord!!")