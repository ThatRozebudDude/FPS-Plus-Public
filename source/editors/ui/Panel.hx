package editors.ui;

import extensions.flixel.FlxTextExt;
import editors.ui.Box;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import shaders.UIBoxShader;
import flixel.util.FlxSignal;
import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

typedef PanelTab = {
	var name:String;
	var tab:Box;
	var title:FlxTextExt;
	var group:FlxTypedSpriteGroup<FlxSprite>;
}

class Panel extends FlxTypedSpriteGroup<FlxSprite>
{

	var panelBackground:Box;
	public var tabs:Array<PanelTab> = [];
	public var selectedTab:Int = 0;

	public function new(_x:Float, _y:Float, _width:Float, _height:Float, _tabs:Array<String>, _tabHeight:Float){
		super(_x, _y);
		if(_tabs.length < 1){ _tabs = [""]; }

		panelBackground = new Box(0, _tabHeight - Box.BORDER_SIZE, _width, _height - (_tabHeight - Box.BORDER_SIZE));

		for(i in 0..._tabs.length){
			var panelTab:PanelTab = {name: _tabs[i], tab: null, title: null, group: null};

			panelTab.tab = new Box(((_width/4)*i) - (Box.BORDER_SIZE * i/(_tabs.length-1)), 0, (_width/4)+Box.BORDER_SIZE, _tabHeight);
			panelTab.tab.onClick.add(function(){ changeTab(i); });

			panelTab.group = new FlxTypedSpriteGroup<FlxSprite>(Box.BORDER_SIZE, _tabHeight);
			panelTab.group.visible = false;
			
			panelTab.title = new FlxTextExt(panelTab.tab.getMidpoint().x, panelTab.tab.getMidpoint().y + 1, (_width/4), panelTab.name, 20);
			panelTab.title.setFormat(Paths.font("cascadia"), panelTab.title.textField.defaultTextFormat.size, UIColors.FILL_TEXT_COLOR, CENTER);
			panelTab.title.y -= panelTab.title.height/2;
			panelTab.title.x -= panelTab.title.width/2;

			tabs.push(panelTab);
		}

		add(panelBackground);
		for(tab in tabs){
			add(tab.tab);
			add(tab.title);
			add(tab.group);
		}

		changeTab(0);
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}

	public function addToTab(tabName:String, obj:FlxSprite):Void{
		for(tab in tabs){
			if(tab.name == tabName){
				tab.group.add(obj);
				return;
			}
		}
		trace('No tab with the name "$tabName" exists.');
	}

	public function changeTab(tabIndex:Int):Void{
		selectedTab = tabIndex;
		for(i in 0...tabs.length){
			if(tabIndex == i){
				tabs[i].tab.fillColor = UIColors.SELECTED_COLOR;
				tabs[i].title.color = UIColors.SELECTED_TEXT_COLOR;
				tabs[i].group.visible = true;
			}
			else{
				tabs[i].tab.fillColor = UIColors.FILL_COLOR;
				tabs[i].title.color = UIColors.FILL_TEXT_COLOR;
				tabs[i].group.visible = false;
			}
		}
	}
	
}