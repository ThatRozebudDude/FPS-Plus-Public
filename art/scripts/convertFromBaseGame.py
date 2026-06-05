import json
import sys
import os
import shutil
from dataclasses import dataclass

FPS_CHART_FORMAT = "fpsplus_1"
PRINT_DEBUG_STUFF = True

@dataclass
class ExtraInfo:
	song:str
	mix:str
	player:str
	opponent:str
	speaker:str
	stage:str

def debugPrint(text:str) -> None:
	if PRINT_DEBUG_STUFF:
		print(text)

def convertDiffNameToSuffix(diff:str) -> str:
	match diff:
		case "erect":
			diff = "normal"
		case "nightmare":
			diff = "hard"
	return diff

def convertCharacter(character:str) -> tuple[str, bool]:
	match character:
		case "bf": return ("Bf", True)
		case "bf-car": return ("BfCar", True)
		case "bf-christmas": return ("BfChristmas", True)
		case "bf-dark": return ("BfDark", True)
		case "bf-holding-gf": return ("BfHoldingGf", True)
		case "bf-pixel": return ("BfPixel", True)
		case "dad": return ("Dad", True)
		case "darnell": return ("Darnell", True)
		case "darnell-blazin": return ("DarnellBlazin", True)
		case "gf": return ("Gf", True)
		case "gf-car": return ("GfCar", True)
		case "gf-christmas": return ("GfChristmas", True)
		case "gf-dark": return ("GfDark", True)
		case "gf-pixel": return ("GfPixel", True)
		case "gf-tankmen": return ("GfTankmen", True)
		case "mom": return ("Mom", True)
		case "mom-car": return ("MomCar", True)
		case "monster": return ("Monster", True)
		case "monster-christmas": return ("MonsterChristmas", True)
		case "nene": return ("Nene", True)
		case "nene-christmas": return ("NeneChristmas", True)
		case "nene-dark": return ("NeneDark", True)
		case "nene-pixel": return ("NenePixel", True)
		case "nene-tankmen": return ("NeneTankmen", True)
		case "otis-speaker": return ("OtisSpeaker", True)
		case "parents-christmas": return ("ParentsChristmas", True)
		case "pico": return ("Pico", True)
		case "pico-blazin": return ("PicoBlazin", True)
		case "pico-christmas": return ("PicoChristmas", True)
		case "pico-dark": return ("PicoDark", True)
		case "pico-holding-nene": return ("PicoHoldingNene", True)
		case "pico-pixel": return ("PicoPixel", True)
		case "pico-playable": return ("Pico", True)
		case "pico-speaker": return ("PicoSpeaker", True)
		case "senpai": return ("Senpai", True)
		case "senpai-angry": return ("SenpaiAngry", True)
		case "spirit": return ("Spirit", True)
		case "spooky": return ("Spooky", True)
		case "spooky-dark": return ("SpookyDark", True)
		case "tankman": return ("Tankman", True)
		case "tankman-bloody": return ("TankmanBloody", True)
	
	print("Character not in dictionary! What is the equivalent for \"" + character + "\": ")
	return (input(), False)

def convertStage(stage:str) -> tuple[str, bool]:
	match stage:
		case "limoRide": return ("Limo", True)
		case "limoRideErect": return ("LimoErect", True)
		case "mainStage": return ("Stage", True)
		case "mainStageErect": return ("StageErect", True)
		case "mallEvil": return ("MallEvil", True)
		case "mallXmas": return ("Mall", True)
		case "mallXmasErect": return ("MallErect", True)
		case "phillyBlazin": return ("PhillyBlazin", True)
		case "phillyStreets": return ("PhillyStreets", True)
		case "phillyStreetsErect": return ("PhillyStreetsErect", True)
		case "phillyTrain": return ("Philly", True)
		case "phillyTrainErect": return ("PhillyErect", True)
		case "school": return ("School", True)
		case "schoolErect": return ("SchoolErect", True)
		case "schoolEvil": return ("SchoolEvil", True)
		case "schoolEvilErect": return ("SchoolEvilErect", True)
		case "spookyMansion": return ("SpookyMansion", True)
		case "spookyMansionErect": return ("SpookyMansionErect", True)
		case "tankmanBattlefield": return ("Tank", True)
		case "tankmanBattlefieldErect": return ("TankErect", True)
	
	print("Stage not in dictionary! What is the equivalent for \"" + stage + "\": ")
	return (input(), False)

def convertAlbum(album:str) -> str:
	match album:
		case "volume1":
			album = "vol1"
		case "volume2":
			album = "vol2"
		case "volume3":
			album = "vol3"
		case "volume4":
			album = "vol4"
		case "expansion1":
			album = "ext1"
		case "expansion2":
			album = "ext2"
	return album

def getBpmAtTime(bpmChanges, time:float) -> float:
	currentBpm:float = bpmChanges[0]["bpm"]
	for bpmChange in bpmChanges:
		if time < bpmChange["t"]:
			currentBpm = bpmChange["bpm"]
	return currentBpm

def processChart(data, meta, diff:str, extraInfo:ExtraInfo) -> str:
	debugPrint("\nProcessing " + diff + " chart.")
	
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
				debugPrint("Hold Duration " + str(round(note["l"])) + "\t>\t" + str(length))
		if "k" in note:
			match note["k"]: # idk if all these are actually used but this is based on the LegacyNotes.hxc stuff.
				case "hey":
					tag = "playAnim;hey"

				case "cheer":
					tag = "playAnim;cheer"
					
				case "ugh":
					tag = "playAnim;ugh"
	
				case "argh":
					tag = "playAnim;argh"

				case "shit":
					tag = "playAnim;shit"

				case "shit-censor":
					tag = "playAnim;shit-censor"

				case "burp":
					tag = "playAnim;burp"

				case "burpBig":
					tag = "playAnim;burpBig"

				case "alt" | "mom":
					tag = "animSet;alt"

				case "censor":
					tag = "animSet;censor"

				case _:
					debugPrint("Case for note type \"" + note["k"] + "\" not handled.")
					tag = note["k"]

		newNote:dict = {
			"time": note["t"],
			"direction": note["d"]%4,
			"length": length,
			"player": note["d"]<4,
			"tag": tag
		}
		notes.append(newNote)

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
	debugPrint("\nProcessing metadata.")

	if "erect" in meta["playData"]["difficulties"]:
		diffs = [0, meta["playData"]["ratings"]["erect"], meta["playData"]["ratings"]["nightmare"]]
		diffSet = "erect"
	else:
		diffs = [meta["playData"]["ratings"]["easy"], meta["playData"]["ratings"]["normal"], meta["playData"]["ratings"]["hard"]]
		diffSet = "standard"

	metaExport:dict = {
		"name": meta["songName"],
		"artist": meta["artist"],
		"album": convertAlbum(meta["playData"]["album"]),
		"difficulties": diffs,
		"difficultySet": diffSet,
		"compatibleInsts": ["#" + extraInfo.song.split("-")[0].lower()],
		"compatableInsts": ["Included for backwards compatibility purposes and to prevent crashes."],
		"mixName": extraInfo.mix
	}

	return json.dumps(metaExport, indent="\t")

def processEvents(data) -> str:
	debugPrint("\nProcessing events.")

	chartScroll:float = data["scrollSpeed"]["hard"]

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

				debugPrint(event["e"] + "\t->\t" + tag[0])

			case "ZoomCamera":
				column[0] = 3

				if "easeDir" in event["v"]:
					tag[0] += "camZoom;" + str(event["v"]["zoom"]) + ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"]) + str(event["v"]["easeDir"])
				else:
					tag[0] += "camZoom;" + str(event["v"]["zoom"]) + ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"])

				if "mode" in event["v"]:
					if event["v"]["mode"] == "stage":
						tag[0] += ";true"

				debugPrint(event["e"] + "\t->\t" + tag[0])

			case "SetCameraBop":
				column[0] = 2
				tag[0] += "camBopFreq;" + str(event["v"]["rate"])

				instensity = 1
				if "intensity" in event["v"]:
					instensity = event["v"]["intensity"]

				tag.append("")
				column[0] = 3
				tag[1] += "camBopIntensity;" + str(instensity)
				timeOffset.append(-20)
				column.append(2)

				debugPrint(event["e"] + "\t->\t" + tag[0] + "\t&\t" + tag[1])

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

				debugPrint(event["e"] + "\t->\t" + tag[0])
				
			case "ScrollSpeed":
				column[0] = 3
				value = event["v"]["scroll"]
				lane = "all"

				if "absolute" in event["v"]:
					if event["v"]["absolute"]:
						value = event["v"]["scroll"]/chartScroll

				if "strumline" in event["v"]:
					if event["v"]["strumline"] == "player":
						lane = "bf"
					elif event["v"]["strumline"] == "opponent":
						lane = "dad"

				if "easeDir" in event["v"]:
					tag[0] += "scrollSpeedMultiplier;" + str(value) + ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"]) + str(event["v"]["easeDir"]) + ";" + lane
				else:
					tag[0] += "scrollSpeedMultiplier;" + str(value) + ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"]) + ";" + lane

				debugPrint(event["e"] + "\t->\t" + tag[0])

			case _:
				skipAdd = True
				print(event["e"] + "\tXX\tEvent not supported, skipping.")

		if not skipAdd:
			for i in range(len(tag)):
				newEvent:dict = {
					"time": max(event["t"] + timeOffset[i], 0),
					"lane": column[i],
					"tag": tag[i]
				}
				events.append(newEvent)

	eventExport:dict = {
		"meta": {
			"format": FPS_CHART_FORMAT
		},
		"events": events
	}

	return json.dumps(eventExport, indent="\t")

if(__name__ == "__main__"):
	with open(sys.argv[2]) as f:
		chartJson = json.load(f)

	with open(sys.argv[3]) as f:
		metaJson = json.load(f)

	print("Song Folder Name: ")
	songName:str = input()
	print("Mix Name: ")
	mixName:str = input()
	playerCharR:tuple[str, bool] = convertCharacter(metaJson["playData"]["characters"]["player"])
	playerChar:str = playerCharR[0]
	if playerCharR[1]:
		debugPrint(metaJson["playData"]["characters"]["player"] + "\t->\t" + playerChar)
	oppCharR:tuple[str, bool] = convertCharacter(metaJson["playData"]["characters"]["opponent"])
	oppChar:str = oppCharR[0]
	if oppCharR[1]:
		debugPrint(metaJson["playData"]["characters"]["opponent"] + "\t->\t" + oppChar)
	gfCharR:tuple[str, bool] = convertCharacter(metaJson["playData"]["characters"]["girlfriend"])
	gfChar:str = gfCharR[0]
	if gfCharR[1]:
		debugPrint(metaJson["playData"]["characters"]["girlfriend"] + "\t->\t" + gfChar)
	stageR:tuple[str, bool] = convertStage(metaJson["playData"]["stage"])
	stage:str = stageR[0]
	if stageR[1]:
		debugPrint(metaJson["playData"]["stage"] + "\t->\t" + stage)

	extraInfo:ExtraInfo = ExtraInfo(songName, mixName, playerChar, oppChar, gfChar, stage)

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
		exit(1)

	print("\nDone!")
	exit(0)