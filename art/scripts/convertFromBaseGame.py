import json
import sys
import os
import shutil
from dataclasses import dataclass

FPS_CHART_FORMAT = "fpsplus_1"

@dataclass
class ExtraInfo:
	song:str
	mix:str
	player:str
	opponent:str
	speaker:str
	stage:str

def convertDiffNameToSuffix(diff) -> str:
    match diff:
        case "erect":
            diff = "normal"
        case "nightmare":
            diff = "hard"
    return diff

def getBpmAtTime(bpmChanges, time:float) -> float:
	currentBpm:float = bpmChanges[0]["bpm"]
	for bpmChange in bpmChanges:
		if time < bpmChange["t"]:
			currentBpm = bpmChange["bpm"]
	return currentBpm

def processChart(data, meta, diff:str, extraInfo:ExtraInfo) -> str:
	bpmChanges = meta["timeChanges"]
	notes:list[dict] = []
	
	for note in data["notes"][diff]:
		stepTime = ((60 / getBpmAtTime(bpmChanges, note["t"])) * 1000) / 4

		length = 0
		tag = ""
		if "l" in note:
			if note["l"] > 0:
				while True:
					if note["l"] > (stepTime * length) + stepTime * 0.9:
						length += 1
					else:
						break
				# print("Hold Duration " + str(round(note["l"])) + "\t>\t" + str(length))
		if "k" in note:
			# do better tag stuff here
			tag = note["k"]

		note:dict = {
			"time": note["t"],
			"direction": note["d"]%4,
			"length": length,
			"player": note["d"]<4,
			"tag": tag
		}
		notes.append(note)

	bpmChangesExport:list[dict] = []
	for bpmChange in bpmChanges:
		change:dict = {
			"time": bpmChange["t"],
			"bpm": bpmChange["bpm"]
		}
		bpmChangesExport.append(change)
	
	chart:dict = {
		"meta": {
			"format": FPS_CHART_FORMAT,
			"song": extraInfo.song,
			"player": extraInfo.player,
			"opponent": extraInfo.opponent,
			"speaker": extraInfo.speaker,
			"stage": extraInfo.stage,
			"scroll": data["scrollSpeed"][diff],
			"bpm": bpmChangesExport
		},
		"notes": notes
	}

	return json.dumps(chart, indent="\t")

def processMetadata(meta, extraInfo:ExtraInfo) -> str:
	if "erect" in meta["playData"]["difficulties"]:
		diffs = [0, meta["playData"]["ratings"]["erect"], meta["playData"]["ratings"]["nightmare"]]
		diffSet = "erect"
	else:
		diffs = [meta["playData"]["ratings"]["easy"], meta["playData"]["ratings"]["normal"], meta["playData"]["ratings"]["hard"]]
		diffSet = "standard"

	metaExport:dict = {
		"name": meta["songName"],
		"artist": meta["artist"],
		"album": meta["playData"]["album"],
		"difficulties": diffs,
		"difficultySet": diffSet,
		"compatibleInsts": ["#" + extraInfo.song.lower()],
		"compatableInsts": ["Included for backwards compatibility purposes and to prevent crashes."],
		"mixName": extraInfo.mix
	}

	return json.dumps(metaExport, indent="\t")

def processEvents(data) -> str:
	events:list[dict] = []

	for event in data["events"]:
		skipAdd = False
		tag = [""]
		column = [0]
		timeOffset = [0]

		match event["e"]:
			case "FocusCamera":

				focusedCharacter = -1
				if type(event["v"]) is int:
					focusedCharacter = event["v"]
				else:
					focusedCharacter = event["v"]["char"]

				match focusedCharacter:
						case 0 | "0":
							tag[0] += "camFocusBf;"
						case 1 | "1":
							tag[0] += "camFocusDad;"
						case 2 | "2":
							tag[0] += "camFocusGf;"

				x = 0
				y = 0
				if type(event["v"]) is not int:
					if "x" in event["v"]:
						x = event["v"]["x"]
					if "y" in event["v"]:
						y = event["v"]["y"]
							
				tag[0] += str(x) + ";" + str(y)

				if type(event["v"]) is not int:
					if "ease" in event["v"]:
						if not event["v"]["ease"] == "CLASSIC":
							if "easeDir" in event["v"]:
								tag[0] += ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"]) + str(event["v"]["easeDir"])
							else:
								tag[0] += ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"])

				print(event["e"] + "\t->\t" + tag[0])

			case "ZoomCamera":
				if "easeDir" in event["v"]:
					tag[0] += "camZoom;" + str(event["v"]["zoom"]) + ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"]) + str(event["v"]["easeDir"])
				else:
					tag[0] += "camZoom;" + str(event["v"]["zoom"]) + ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"])

				if "mode" in event["v"]:
					if event["v"]["mode"] == "stage":
						tag[0] += ";true"

				print(event["e"] + "\t->\t" + tag[0])

			case "SetCameraBop":
				tag[0] += "camBopFreq;" + str(event["v"]["rate"])

				instensity = 1
				if "intensity" in event["v"]:
					instensity = event["v"]["intensity"]

				tag.append("")
				tag[1] += "camBopIntensity;" + str(instensity)
				timeOffset.append(-20)
				column.append(2)

				print(event["e"] + "\t->\t" + tag[0] + "\t&\t" + tag[1])

			case "PlayAnimation":
				column[0] = 1
				target = "bf"
				match event["v"]["target"]:
					case "dad":
						target = "dad"
					case "girlfriend" | "gf": #idk which one it is
						target = "gf"

				force = "false"
				if "force" in event["v"]:
					if event["v"]["force"] == "true":
						force = "true"

				tag[0] += "playAnim;" + target + ";" + event["v"]["anim"] + ";" + force

				print(event["e"] + "\t->\t" + tag[0])

			case _:
				skipAdd = True
				print(event["e"] + "\tXX\tEvent not supported, skipping.")

		if not skipAdd:
			for i in range(len(tag)):
				event:dict = {
					"time": event["t"] + timeOffset[i],
					"lane": column[i],
					"tag": tag[i]
				}
				events.append(event)

	eventExport:dict = {
		"meta": {
			"format": FPS_CHART_FORMAT
		},
		"events": events
	}

	return json.dumps(eventExport, indent="\t")

if(__name__ == "__main__"):
	print("Song Folder Name: ")
	songName = input()
	print("Mix Name: ")
	mixName = input()
	print("Player Character: ")
	playerChar = input()
	print("Opponent Character: ")
	oppChar = input()
	print("Speaker Character: ")
	gfChar = input()
	print("Stage: ")
	stage = input()

	extraInfo:ExtraInfo = ExtraInfo(songName, mixName, playerChar, oppChar, gfChar, stage)

	with open(sys.argv[2]) as f:
		chartJson = json.load(f)

	with open(sys.argv[3]) as f:
		metaJson = json.load(f)

	dir = os.path.dirname(os.path.realpath(__file__))
	outputFolder = dir + "\\convertedSongs\\" + songName.lower()
	if sys.platform == "darwin" or sys.platform == "linux":
		outputFolder = outputFolder.replace("\\", "/")
	if not os.path.exists(outputFolder):
		os.makedirs(outputFolder)
	else:
		try:
			shutil.rmtree(outputFolder)
		except OSError as e:
			print("Error: %s - %s." % (e.filename, e.strerror))
			exit(1)
		os.makedirs(outputFolder)

	# Full convert, does chart events and metadata.
	if sys.argv[1] == "-f" or sys.argv[1] == "-full":
		if "erect" not in metaJson["playData"]["difficulties"]:
			charts = [processChart(chartJson, metaJson, "easy", extraInfo), processChart(chartJson, metaJson, "normal", extraInfo), processChart(chartJson, metaJson, "hard", extraInfo)]
			extensions = ["easy", "normal", "hard"]

		else:
			charts = [processChart(chartJson, metaJson, "erect", extraInfo), processChart(chartJson, metaJson, "nightmare", extraInfo)]
			extensions = ["normal", "hard"]

		metadata = processMetadata(metaJson, extraInfo)
		events = processEvents(chartJson)

		for i in range(len(charts)):
			if sys.platform == "darwin" or sys.platform == "linux":
				f = open(outputFolder + "/chart-"+extensions[i]+".json", "w")
			else:
				f = open(outputFolder + "\\chart-"+extensions[i]+".json", "w")
			f.write(charts[i])
			f.close()

		f = open(outputFolder + "\\events.json", "w")
		f.write(events)
		f.close()

		f = open(outputFolder + "\\meta.json", "w")
		f.write(metadata)
		f.close()

	# Converts all charts (no events).
	elif sys.argv[1] == "-cs" or sys.argv[1] == "-charts":
		if "erect" not in metaJson["playData"]["difficulties"]:
			charts = [processChart(chartJson, metaJson, "easy", extraInfo), processChart(chartJson, metaJson, "normal", extraInfo), processChart(chartJson, metaJson, "hard", extraInfo)]
			extensions = ["easy", "normal", "hard"]

		else:
			charts = [processChart(chartJson, metaJson, "erect", extraInfo), processChart(chartJson, metaJson, "nightmare", extraInfo)]
			extensions = ["normal", "hard"]

		for i in range(len(charts)):
			if sys.platform == "darwin" or sys.platform == "linux":
				f = open(outputFolder + "/chart-"+extensions[i]+".json", "w")
			else:
				f = open(outputFolder + "\\chart-"+extensions[i]+".json", "w")
			f.write(charts[i])
			f.close()

	# Converts a specific chart (no events).
	elif sys.argv[1] == "-c" or sys.argv[1] == "-chart":
		print("Difficulty: ")
		inputDiff = input()

		chart = processChart(chartJson, metaJson, inputDiff, extraInfo)
		if sys.platform == "darwin" or sys.platform == "linux":
			f = open(outputFolder + "/chart-"+convertDiffNameToSuffix(inputDiff)+".json", "w")
		else:
			f = open(outputFolder + "\\chart-"+convertDiffNameToSuffix(inputDiff)+".json", "w")
		f.write(chart)
		f.close()

	# Converts only the events.
	elif sys.argv[1] == "-e" or sys.argv[1] == "-events":
		events = processEvents(chartJson)
		f = open(outputFolder + "\\events.json", "w")
		f.write(events)
		f.close()

	# Converts only the song metadata.
	elif sys.argv[1] == "-m" or sys.argv[1] == "-meta":
		metadata = processMetadata(metaJson, extraInfo)
		f = open(outputFolder + "\\meta.json", "w")
		f.write(metadata)
		f.close()

	# You fucked up.
	else:
		print("Argument not recognized, use \"-full\", \"-chart\", \"-charts\", \"-events\", or \"-meta\".")